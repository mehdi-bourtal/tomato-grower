#include "https_handler.h"
#include <HTTPClient.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>

static unsigned long lastUpdate = 0;
const unsigned long updateInterval = 5000; 

void loop_https() {
  if (millis() - lastUpdate > updateInterval) {
    lastUpdate = millis();

    SensorData currentData = {
      "4eaz-yhe09-IOL9U7", 
      80.5, 
      10.0, 
      20.0, 
      6600  
    };

    ActionResponse response = send_data_https(currentData);

    Serial.print("status: ");
    Serial.print(response.status_code);
    Serial.print(" | watering: ");
    Serial.print(response.watering ? "true" : "false");
    Serial.print(" | volume: ");
    Serial.println(response.volume);
  }
}


ActionResponse send_data_https(SensorData data) {
  // Inicializa a resposta com valores por defeito
  ActionResponse result = {0, "", false, 0}; 

  if (WiFi.status() == WL_CONNECTED) {
    WiFiClientSecure *client = new WiFiClientSecure;
    client->setInsecure(); 

    HTTPClient https;
    const char* serverUrl = "https://mehdi-bourtal69--tomato-grower-app-run-pipeline.modal.run";

    if (https.begin(*client, serverUrl)) {
      https.addHeader("Content-Type", "application/json");

      JsonDocument docOut;
      docOut["sentFrom"] = "uP";
      docOut["proc_id"] = data.proc_id;
      docOut["temperature"] = data.temperature;
      docOut["humidity_int"] = data.humidity_int;
      docOut["humidity_ext"] = data.humidity_ext;
      docOut["luminosity"] = data.luminosity;

      String jsonPayload;
      serializeJson(docOut, jsonPayload);

      //ENVOYER
      int httpResponseCode = https.POST(jsonPayload);

      if (httpResponseCode > 0) {
        String response = https.getString();
        
        //RECEVOIR
        JsonDocument docIn;
        DeserializationError error = deserializeJson(docIn, response);

        if (!error) {
          result.status_code = docIn["status_code"] | httpResponseCode;
          result.proc_id = docIn["proc_id"].as<String>();
          result.watering = docIn["watering"] | false;
          result.volume = docIn["volume"] | 0;
          
          //Serial.println("JSON ok");
        } else {
          Serial.print("error avec JSON : ");
          Serial.println(error.c_str());
        }
      } else {
        Serial.print("Error dans le POST: ");
        Serial.println(httpResponseCode);
      }
      https.end();
    }
    delete client;
  }
  return result;
}