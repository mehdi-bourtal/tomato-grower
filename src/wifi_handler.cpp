#include <Arduino.h>
#include <WiFi.h>
#include <WiFiManager.h>
#include "wifi_handler.h"

void setup_wifi() {
  WiFiManager wm;
  Serial.println("Iniciando WiFiManager...");
  
  bool res = wm.autoConnect("ESP32_Config", "12345678");

  if(!res) {
    Serial.println("Falha ao conectar e timeout atingido");
    ESP.restart();
  } else {
    Serial.print("\nWiFi conectado! IP: ");
    Serial.println(WiFi.localIP());
  }
}

bool is_wifi_connected() {
  return WiFi.status() == WL_CONNECTED;
}