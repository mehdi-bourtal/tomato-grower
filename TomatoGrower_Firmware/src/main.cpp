#include <Arduino.h>
#include "wifi_handler.h"
#include "mqtt_handler.h"

void setup() {
  Serial.begin(115200);

  setup_wifi();
  setup_mqtt();
}

void loop() {
  if (!is_wifi_connected()) {
    Serial.println("Connexion Wi-Fi perdue...");
    delay(5000);
    return; 
  }

  //Mantém o MQTT vivo e escutando as mensagens do servidor
  loop_mqtt();
}


// teste teste