#include "LumiereController.h"

LumiereController::LumiereController(int analogPin, AsyncWebServer* server, GestionnaireEvenements* gestionnaireEvenements) 
    : _analogPin(analogPin), _server(server), _gestionnaireEvenements(gestionnaireEvenements) {}

float LumiereController::getLuminosity() {
    float Vout = analogRead(_analogPin) * 3.3 / 4095.0; // Convertir la lecture analogique en tension
    return Vout; // Retourne la tension pour le moment.
}

void LumiereController::init() {
    
    _server->on("/luminosity/control/on", HTTP_GET, [this](AsyncWebServerRequest* request){
        _luminosityControlEnabled = true;
        request->send(200, "text/plain", "Contrôle de luminosité activé");
    });

    _server->on("/luminosity/control/off", HTTP_GET, [this](AsyncWebServerRequest* request){
        _luminosityControlEnabled = false;
        request->send(200, "text/plain", "Contrôle de luminosité désactivé");
    }); 

    _server->on("/luminosity/status", HTTP_GET, [this](AsyncWebServerRequest* request){
    float luminosite = this->getLuminosity();
    bool luminosityControlState = _luminosityControlEnabled;
    float luminosityThreshold = _luminosityThreshold;

    // Construction de l'objet JSON
    DynamicJsonDocument doc(1024);
    doc["luminosity"] = luminosite;
    doc["controlEnabled"] = luminosityControlState;
    doc["threshold"] = luminosityThreshold;

    String response;
    serializeJson(doc, response); // Convertit l'objet JSON en chaîne de caractères

    request->send(200, "application/json", response);
});

    _server->on("/luminosity/threshold", HTTP_PUT, [this](AsyncWebServerRequest* request) {},
    NULL,
    [this](AsyncWebServerRequest* request, uint8_t* data, size_t len, size_t index, size_t total) {
        DynamicJsonDocument doc(1024);
        deserializeJson(doc, (const char*)data);
        if (doc.containsKey("value")) {
            float value = doc["value"]; 
            _luminosityThreshold = value;
            request->send(200, "text/plain", "Seuil de luminosité réglé");
        } else {
            request->send(400, "text/plain", "Paramètre 'value' manquant");
        }
});

    _server->on("/luminosity", HTTP_GET, [this](AsyncWebServerRequest* request){
        float luminosite = this->getLuminosity();
        String response = String(luminosite) + "V";
        request->send(200, "text/plain", response);
    });

   


}

void LumiereController::handle() {
    if(_luminosityControlEnabled) {
        float luminosite = getLuminosity();
        bool estEnDessousDuSeuil = luminosite < _luminosityThreshold;
        _gestionnaireEvenements->notifierObservateurs("luminosite", estEnDessousDuSeuil);
    }
}



