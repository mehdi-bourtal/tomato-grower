#include <Arduino.h>
#include "driver/mcpwm.h"
#include <esp_task_wdt.h> 
#include "mppt_handler.h"

// Definições restritas a este arquivo
#define PIN_ADC_VPV 34       
#define PIN_ADC_IOUT 35      
#define PIN_PWM_HIN 25       // High Side
#define PIN_PWM_LIN 26       // Low Side

const float V_REF = 3.3;             
const float VPV_DIVIDER = 7.6666;    
const float IOUT_FACTOR = 5.0;       
const int NUM_SAMPLES = 100;       
const int WDT_TIMEOUT = 3;           

// Variáveis de estado do algoritmo MPPT (Globais para este arquivo)
static float duty = 0.10; 
static float step = 0.01;
static int direction = 1;
static float P_old = 0.0;

void setup_mppt() {
    //esp_task_wdt_init(WDT_TIMEOUT, true); 
    //esp_task_wdt_add(NULL);                       //LEMBRAR DE ATIVAR DEPOIS  

    mcpwm_gpio_init(MCPWM_UNIT_0, MCPWM0A, PIN_PWM_HIN); 
    mcpwm_gpio_init(MCPWM_UNIT_0, MCPWM1A, PIN_PWM_LIN); 

    mcpwm_config_t pwm_config;
    pwm_config.frequency = 10000;    // 10 kHz (Período = 100µs)
    pwm_config.cmpr_a = duty * 100.0;     
    pwm_config.counter_mode = MCPWM_UP_COUNTER;
    pwm_config.duty_mode = MCPWM_DUTY_MODE_0;

    // Timer 0 (HIN)
    mcpwm_init(MCPWM_UNIT_0, MCPWM_TIMER_0, &pwm_config); 

    // Timer 1 (LIN) - Fixo a 1%
    pwm_config.cmpr_a = 1.0; 
    mcpwm_init(MCPWM_UNIT_0, MCPWM_TIMER_1, &pwm_config);

    float defasagem = 10; // graus
    mcpwm_set_timer_sync_output(MCPWM_UNIT_0, MCPWM_TIMER_0, MCPWM_SWSYNC_SOURCE_TEZ);
    mcpwm_sync_enable(MCPWM_UNIT_0, MCPWM_TIMER_1, MCPWM_SELECT_TIMER0_SYNC, ((defasagem/360)*1000));

    Serial.println("Starting MPPT (Oversampling Average + Phase Shift 28 + WDT)...");
    delay(1000);
}

void loop_mppt() {
    esp_task_wdt_reset();

    long sum_vpv_raw = 0;
    long sum_iout_raw = 0;

    // Oversampling
    for (int i = 0; i < NUM_SAMPLES; i++) {
        sum_vpv_raw += analogRead(PIN_ADC_VPV);
        sum_iout_raw += analogRead(PIN_ADC_IOUT);
    }

    float adc_vpv_raw = sum_vpv_raw / (float)NUM_SAMPLES;
    float adc_iout_raw = sum_iout_raw / (float)NUM_SAMPLES;

    float v_pin_vpv = (adc_vpv_raw / 4095.0) * V_REF;
    float Vpv = v_pin_vpv * VPV_DIVIDER;

    float v_pin_iout = (adc_iout_raw / 4095.0) * V_REF;
    float Iout = v_pin_iout / IOUT_FACTOR;

    float P_now = Vpv * Iout;

    // Lógica Perturb and Observe (P&O)
    if (Vpv > 12.5) { 
        if (P_now <= P_old) {
            direction *= -1; // Inverte a direção se a potência caiu
        }

        duty += (direction * step);

        if (duty > 0.85) duty = 0.85; 
        if (duty < 0.05) duty = 0.05;

    } else {
        duty = 0;
        P_now = 0;
    }

    float duty_percent = duty * 100.0;
    mcpwm_set_duty(MCPWM_UNIT_0, MCPWM_TIMER_0, MCPWM_OPR_A, duty_percent);

    P_old = P_now;

    Serial.print("Pnow: "); Serial.print(P_now); Serial.print(" W | ");
    Serial.print("Duty HIN (%): "); Serial.println(duty_percent);
}