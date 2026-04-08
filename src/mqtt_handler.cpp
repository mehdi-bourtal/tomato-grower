#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include "mqtt_handler.h"

//Credenciais do HiveMQ Cloud
const char* mqtt_server = "26c04a37767a41229e829ec040d66f2a.s1.eu.hivemq.cloud";
const int mqtt_port = 8883; 
const char* mqtt_user = "Gustavo1";
const char* mqtt_pass = "Gustavo1";

WiFiClientSecure espClient;
PubSubClient client(espClient);

//Função chamada automaticamente quando chega uma mensagem do servidor
void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Servidor enviou mensagem no tópico [");
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
    Serial.print("Conectando ao HiveMQ Cloud...");
    
    //Gera um ID de cliente aleatório
    String clientId = "ESP32-Subscriber-" + String(random(0, 1000));
    
    //Conecta passando usuário e senha
    if (client.connect(clientId.c_str(), mqtt_user, mqtt_pass)) { 
      Serial.println("Conectado!");
      
      client.subscribe("tomato_grower/6c9e56c4-ceae-4088-b77b-bb2d034413a0/water"); 
      Serial.println("Inscrito no tópico de escuta.");
      
    } else {
      Serial.print("Falhou, erro=");
      Serial.print(client.state());
      Serial.println(" Tentando novamente em 5 segundos...");
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