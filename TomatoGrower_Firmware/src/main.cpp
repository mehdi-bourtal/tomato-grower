#include <Arduino.h>
#include "wifi_handler.h"
#include "mqtt_handler.h"
#include "https_handler.h"
#include "mppt_handler.h"

void setup() {
  Serial.begin(115200);

  setup_wifi();
  setup_mqtt();
  //setup_mppt();
}

void loop() {

  if (!is_wifi_connected()) {
    Serial.println("Connexion Wi-Fi perdue...");
    delay(5000);
    return; 
  }

  loop_mqtt();
  loop_https();
  //loop_mppt();
}