#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include "mqtt_handler.h"

//Credenciais do HiveMQ Cloud
const char* mqtt_server = "889ddca0deb944699b62db04e0dd80ed.s1.eu.hivemq.cloud";
const int mqtt_port = 8883; 
const char* mqtt_user = "gustavo";
const char* mqtt_pass = "Teste123";

WiFiClientSecure espClient;
PubSubClient client(espClient);

//Função chamada automaticamente quando chega uma mensagem do servidor
void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("message reçu dans [");
  Serial.print(topic);
  Serial.print("]: ");
  
  String mensagemRecebida;
  for (int i = 0; i < length; i++) {
    mensagemRecebida += (char)payload[i];
  }

  Serial.println(mensagemRecebida);
}

//Função interna de reconexão
void reconnect() {
  while (!client.connected()) {
    Serial.print("Connecting HiveMQ Cloud...");
    
    // 1. Gera um ID único baseado no endereço MAC do chip
    String clientId = "ESP32-";
    clientId += String((uint32_t)ESP.getEfuseMac(), HEX);

    // 2. Tenta conectar usando o ID gerado dinamicamente
    if (client.connect(clientId.c_str(), mqtt_user, mqtt_pass)) { 
      client.subscribe("tomato_grower/teste/water");
      Serial.print("Conectado com ID: ");
      Serial.println(clientId);
      Serial.println("Abonné au fil d'écoute");
    } else { 
      Serial.print("Failed, error=");
      Serial.print(client.state());
      Serial.println(" réessaye dans 5 secondes...");
      delay(5000);
    }
  }
}

void setup_mqtt() {
  //Configura o cliente seguro para ignorar a verificação de certificado raiz
  espClient.setInsecure(); 
  
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
}

void loop_mqtt() {
  if (!client.connected()) {
    reconnect();
  }
  //Mantém a conexão viva e processa as mensagens recebidas
  client.loop(); 
}