#include "TemperatureController.h"

const float TemperatureController::R1 = 10000.0; // résistance fixe
const float TemperatureController::T0 = 25.0 + 273.15; // Température de référence en Kelvin
const float TemperatureController::R0 = 10000.0; // Résistance du thermistor à T0
const float TemperatureController::B = 3950.0; // Coefficient B

TemperatureController::TemperatureController(int analogPin, AsyncWebServer* server, GestionnaireEvenements* gestionnaireEvenements) 
    : _analogPin(analogPin), _server(server), _gestionnaireEvenements(gestionnaireEvenements) {}


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

    _server->on("/temperature/control/on", HTTP_GET, [this](AsyncWebServerRequest* request){
        _temperatureControlEnabled = true;
        request->send(200, "text/plain", "Contrôle de température activé");
    });

    _server->on("/temperature/control/off", HTTP_GET, [this](AsyncWebServerRequest* request){
        _temperatureControlEnabled = false;
        request->send(200, "text/plain", "Contrôle de température désactivé");
    });

    _server->on("/temperature/seuil", HTTP_GET, [this](AsyncWebServerRequest* request){
        if (request->hasParam("valeur")) {
            _temperatureThreshold = request->getParam("valeur")->value().toFloat();
            request->send(200, "text/plain", "Seuil de température réglé");
        } else {
            request->send(400, "text/plain", "Paramètre 'valeur' manquant");
        }
    });

    _server->on("/temperature", HTTP_GET, [this](AsyncWebServerRequest* request){
        float temperature = this->getTemperature();
        String response = String(temperature) + "°C";
        request->send(200, "text/plain", response);
    });

}

void TemperatureController::handle() {
    if(_temperatureControlEnabled) {
        float temperature = getTemperature();
        bool estEnDessousDuSeuil = temperature < _temperatureThreshold;
        _gestionnaireEvenements->notifierObservateurs("temperature", estEnDessousDuSeuil);
    }
}
