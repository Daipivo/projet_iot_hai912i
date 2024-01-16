#include "LuminosityController.h"
#include "FirebaseManager.h"

// Constructor
LuminosityController::LuminosityController(int analogPin, AsyncWebServer* server, EventManager* eventManager) 
    : _analogPin(analogPin), _server(server), _eventManager(eventManager) {}

// Return current luminosity
float LuminosityController::getLuminosity() {
    
    // Get tension value
    float Vout = analogRead(_analogPin) * 3.3 / 4095.0; 
    return Vout; 
}

// Init server routes
void LuminosityController::init() {
    
    _server->on("/api/luminosity/control", HTTP_PATCH, [this](AsyncWebServerRequest* request) {},
    NULL,
    [this](AsyncWebServerRequest* request, uint8_t* data, size_t len, size_t index, size_t total) {
    
    DynamicJsonDocument doc(128);
    deserializeJson(doc, (const char*)data);

    if (doc.containsKey("state")) {
        String state = doc["state"].as<String>();
        if (state == "on") {
            _luminosityControlEnabled = true;
            request->send(200, "text/plain", "Contrôle de luminosité activé");
        } else if (state == "off") {
            _luminosityControlEnabled = false;
            request->send(200, "text/plain", "Contrôle de luminosité désactivé");
        } else {
            request->send(400, "text/plain", "État invalide");
        }
    } else {
        request->send(400, "text/plain", "Paramètre 'state' manquant");
    }
  });


    _server->on("/api/luminosity/status", HTTP_GET, [this](AsyncWebServerRequest* request){

    float luminosite = this->getLuminosity();
    bool luminosityControlState = _luminosityControlEnabled;
    float luminosityThreshold = _luminosityThreshold;
 
    
    FirebaseManager::getInstance().sendSensorData(luminosite, "luminosity");

    DynamicJsonDocument doc(256);
    doc["luminosity"] = luminosite;
    doc["controlEnabled"] = luminosityControlState;
    doc["threshold"] = luminosityThreshold;

    String response;
    serializeJson(doc, response); 

    request->send(200, "application/json", response);
});

    _server->on("/api/luminosity/threshold", HTTP_PATCH, [this](AsyncWebServerRequest* request) {},
    NULL,
    [this](AsyncWebServerRequest* request, uint8_t* data, size_t len, size_t index, size_t total) {
        DynamicJsonDocument doc(128);
        deserializeJson(doc, (const char*)data);
        if (doc.containsKey("value")) {
            float value = doc["value"]; 
            _luminosityThreshold = value;
            request->send(200, "text/plain", "Seuil de luminosité réglé");
        } else {
            request->send(400, "text/plain", "Paramètre 'value' manquant");
        }
});

    _server->on("/api/luminosity", HTTP_GET, [this](AsyncWebServerRequest* request){
        float luminosite = this->getLuminosity();
        String response = String(luminosite) + "V";
        request->send(200, "text/plain", response);
    });

   


}

// Handle periodic
void LuminosityController::handle() {
    if(_luminosityControlEnabled) {
        float luminosite = getLuminosity();
        bool estEnDessousDuSeuil = luminosite < _luminosityThreshold;
        _eventManager->notifyObserver("luminosite", estEnDessousDuSeuil);
    }
}



