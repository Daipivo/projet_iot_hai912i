#include "LumiereController.h"

LumiereController::LumiereController(int analogPin, AsyncWebServer* server, GestionnaireEvenements* gestionnaireEvenements) 
    : _analogPin(analogPin), _server(server), _gestionnaireEvenements(gestionnaireEvenements) {}

float LumiereController::getLuminosity() {
    float Vout = analogRead(_analogPin) * 3.3 / 4095.0; // Convertir la lecture analogique en tension
    return Vout; // Retourne la tension pour le moment.
}

void LumiereController::init() {
    
    _server->on("/luminosite/control/on", HTTP_GET, [this](AsyncWebServerRequest* request){
        _luminosityControlEnabled = true;
        request->send(200, "text/plain", "Contrôle de luminosité activé");
    });

    _server->on("/luminosite/control/off", HTTP_GET, [this](AsyncWebServerRequest* request){
        _luminosityControlEnabled = false;
        request->send(200, "text/plain", "Contrôle de luminosité désactivé");
    }); 

    _server->on("/luminosite/seuil", HTTP_GET, [this](AsyncWebServerRequest* request){
        if (request->hasParam("valeur")) {
            _luminosityThreshold = request->getParam("valeur")->value().toFloat();
            request->send(200, "text/plain", "Seuil de luminosité réglé");
        } else {
            request->send(400, "text/plain", "Paramètre 'valeur' manquant");
        }
    });

    _server->on("/luminosite", HTTP_GET, [this](AsyncWebServerRequest* request){
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



