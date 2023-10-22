#include "LEDController.h"

LEDController::LEDController(int analogPin, AsyncWebServer *server) 
    : _analogPin(analogPin), _server(server) {}

void LEDController::init() {

    _server->on("/led/on", HTTP_GET, [this](AsyncWebServerRequest *request){
    digitalWrite(_analogPin, HIGH);
    request->send(200, "text/plain", "LED allumée");});

    _server->on("/led/off", HTTP_GET, [this](AsyncWebServerRequest *request){
    digitalWrite(_analogPin, LOW);
    request->send(200, "text/plain", "LED éteinte");});

}

void LEDController::handle() {
    // Si votre serveur web nécessite une gestion périodique, faites-le ici
}
