#ifndef HTTPS_HANDLER_H
#define HTTPS_HANDLER_H

#include <Arduino.h>

//Structure des données du capteur (Envoi)
struct SensorData {
  String proc_id;
  float temperature;
  float humidity_int;
  float humidity_ext;
  int luminosity;
};

//Structure de la réponse du serveur (Réception)
struct ActionResponse {
  int status_code;
  String proc_id;
  bool watering;
  int volume;
};

ActionResponse send_data_https(SensorData data);
void loop_https();

#endif