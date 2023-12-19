#include "TemperatureController.h"

const float TemperatureController::R1 = 10000.0; // résistance fixe
const float TemperatureController::T0 = 25.0 + 273.15; // Température de référence en Kelvin
const float TemperatureController::R0 = 10000.0; // Résistance du thermistor à T0
const float TemperatureController::B = 3950.0; // Coefficient B

TemperatureController::TemperatureController(int analogPin, AsyncWebServer& server) 
    : _analogPin(analogPin), _server(server) {}

float TemperatureController::getTemperature() {
    float Vout = analogRead(_analogPin) * 3.3 / 4095.0;
    float R2 = R1 * (3.3 - Vout) / Vout;
    
    // Utilisation de la formule de Steinhart-Hart
    float lnR2 = log(R2 / R0);
    float tempK = 1.0 / ((1.0 / T0) + (1.0 / B) * lnR2);
    float tempC = tempK - 273.15;
    
    return tempC;
}

void TemperatureController::init() {
    _server->on("/temperature", HTTP_GET, [this](AsyncWebServerRequest& request){
        float temperature = this->getTemperature();
        String response = String(temperature) + "°C";
        request->send(200, "text/plain", response);
    });

}

void TemperatureController::handle() {
    // Si votre serveur web nécessite une gestion périodique, faites-le ici
}
