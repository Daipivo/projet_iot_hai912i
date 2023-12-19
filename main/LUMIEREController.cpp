#include "LUMIEREController.h"

LUMIEREController::LUMIEREController(int analogPin, AsyncWebServer* server) 
    : _analogPin(analogPin), _server(server) {}

float LUMIEREController::getLuminosity() {
    float Vout = analogRead(_analogPin) * 3.3 / 4095.0; // Convertir la lecture analogique en tension
    return Vout; // Retourne la tension pour le moment.
}

void LUMIEREController::init() {
    _server->on("/luminosite", HTTP_GET, [this](AsyncWebServerRequest *request){
        float luminosite = this->getLuminosity();
        String response = String(luminosite) + "V";
        request->send(200, "text/plain", response);
    });

}

void LUMIEREController::handle() {
  float luminosite = getLuminosity();
  Serial.print("Luminosité actuelle: ");
  Serial.print(luminosite);
  Serial.println(" V");

  // Ajouter un délai pour ne pas saturer le moniteur série
  delay(1000); // Attendre une seconde
}
