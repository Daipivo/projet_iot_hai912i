#include "LedController.h"

LedController::LedController(int analogPin, AsyncWebServer& server) 
    : _analogPin(analogPin), _server(server) {}

void LedController::init() {

    pinMode(_analogPin, OUTPUT); 
        
    _server->on("/led/on", HTTP_GET, [this](AsyncWebServerRequest& request){
        digitalWrite(_analogPin, HIGH);
        request->send(200, "text/plain; charset=utf-8", "LED allumée");
    });

    _server->on("/led/off", HTTP_GET, [this](AsyncWebServerRequest& request){
        digitalWrite(_analogPin, LOW);
        request->send(200, "text/plain; charset=utf-8", "LED éteinte");
    });

}

void LedController::handle() {
    // Si votre serveur web nécessite une gestion périodique, faites-le ici
}
