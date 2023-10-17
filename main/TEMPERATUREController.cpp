#include "TEMPERATUREController.h"

const float TEMPERATUREController::R1 = 10000.0;
const float TEMPERATUREController::T1 = 25.0 + 273.15;
const float TEMPERATUREController::R0 = 10000.0;
const float TEMPERATUREController::B = 3950.0;

TEMPERATUREController::TEMPERATUREController(int analogPin, AsyncWebServer& server) 
    : _analogPin(analogPin), _server(server) {}

float TEMPERATUREController::getTemperature() {
    float Vout = analogRead(_analogPin) * 3.3 / 4095.0;
    float R2 = R1 * (3.3 - Vout) / Vout;
    float lnR2 = log(R2);
    float tempK = 1.0 / (1.0 / T1 + lnR2 / B);
    float tempC = tempK - 273.15;

    return tempC;
}

void TEMPERATUREController::init() {
    _server.on("/temperature", HTTP_GET, [this](AsyncWebServerRequest *request){
        float temperature = this->getTemperature();
        String response = String(temperature) + "°C";
        request->send(200, "text/plain", response);
    });
}

void TEMPERATUREController::handle() {
    // Si votre serveur web nécessite une gestion périodique, faites-le ici
}
