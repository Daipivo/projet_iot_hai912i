#include "TemperatureController.h"
#include "FirebaseManager.h"

const float TemperatureController::R1 = 10000.0; // résistance fixe
const float TemperatureController::T0 = 25.0;
const float TemperatureController::R0 = 10000.0; // Résistance du thermistor à T0
const float TemperatureController::B = 3950.0; // Coefficient B

TemperatureController::TemperatureController(int analogPin, AsyncWebServer* server, EventManager* eventManager) 
    : _analogPin(analogPin), _server(server), _eventManager(eventManager) {}


float TemperatureController::getTemperature() {
    float Vout = analogRead(_analogPin) * 3.3 / 4095.0;
    float R2 = (R1 * Vout) / (Vout - 3.3);
    // float 
    // float R2 = R1 / (3.3 / Vout - 1.0);
    // float R2 = ((3.3 - R1) - (R1 * Vout)) / Vout; 
    // Utilisation de la formule de Steinhart-Hart
    float lnR2 = log(R2 / R0);

    Serial.print("1 => " + String(Vout));
    Serial.print("2 => " + String(R2));



    float tempC = 1.0 / ((1.0 / T0) + (1.0 / B) * lnR2);
    
    return tempC;
}

void TemperatureController::init() {

    _server->on("/api/temperature/control", HTTP_PATCH, [this](AsyncWebServerRequest* request) {},
    NULL,
    [this](AsyncWebServerRequest* request, uint8_t* data, size_t len, size_t index, size_t total) {
    DynamicJsonDocument doc(128);
    deserializeJson(doc, (const char*)data);

    if (doc.containsKey("state")) {
        String state = doc["state"].as<String>();
        if (state == "on") {
            _temperatureControlEnabled = true;
            request->send(200, "text/plain", "Contrôle de température activé");
        } else if (state == "off") {
            _temperatureControlEnabled = false;
            request->send(200, "text/plain", "Contrôle de température désactivé");
        } else {
            request->send(400, "text/plain", "État invalide");
        }
    } else {
        request->send(400, "text/plain", "Paramètre 'state' manquant");
    }
  });


    _server->on("/api/temperature/status", HTTP_GET, [this](AsyncWebServerRequest* request){

    float temperature = this->getTemperature();
    bool temperatureControlState = _temperatureControlEnabled;
    float temperatureThreshold = _temperatureThreshold;


    FirebaseManager::getInstance().sendSensorData(temperature, "temperature");
    // Construction de l'objet JSON
    DynamicJsonDocument doc(256);
    doc["temperature"] = temperature;
    doc["controlEnabled"] = temperatureControlState;
    doc["threshold"] = temperatureThreshold;

    String response;
    serializeJson(doc, response); // Convertit l'objet JSON en chaîne de caractères

    serializeJsonPretty(doc, Serial);
    request->send(200, "application/json", response);
    
    });

   _server->on("/api/temperature/threshold", HTTP_PATCH, [this](AsyncWebServerRequest* request) {},
    NULL,
    [this](AsyncWebServerRequest* request, uint8_t* data, size_t len, size_t index, size_t total) {
        DynamicJsonDocument doc(128);
        deserializeJson(doc, (const char*)data);
        if (doc.containsKey("value")) {
            float value = doc["value"]; 
            _temperatureThreshold = value;
            request->send(200, "text/plain", "Seuil de température réglé");
        } else {
            request->send(400, "text/plain", "Paramètre 'value' manquant");
        }
});



    _server->on("/api/temperature", HTTP_GET, [this](AsyncWebServerRequest* request){
        float temperature = this->getTemperature();
        String response = String(temperature) + "°C";
        request->send(200, "text/plain", response);
    });

}

void TemperatureController::handle() {
    if(_temperatureControlEnabled) {
        float temperature = getTemperature();
        bool estEnDessousDuSeuil = temperature < _temperatureThreshold;
        _eventManager->notifyObserver("temperature", estEnDessousDuSeuil);
    }
}
