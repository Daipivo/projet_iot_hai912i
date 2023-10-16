#include "LEDController.h"

LEDController::LEDController() : server(80) {}

void LEDController::init() {

    server.on("/test", HTTP_GET, [](AsyncWebServerRequest *request){
    request->send(200, "text/plain", "Coucou")});


    server.on("/led/on", HTTP_GET, [this](AsyncWebServerRequest *request){
    digitalWrite(_ledPin, HIGH);
    request->send(200, "text/plain", "LED allumée")});

    server.on("/led/on", HTTP_GET, [this](AsyncWebServerRequest *request){
    digitalWrite(_ledPin, HIGH);
    request->send(200, "text/plain", "LED allumée");
    });

    // Ajoutez d'autres routes si nécessaire

    server.begin();  // Démarre le serveur web
}

void LEDController::setLedPin(int ledPin) {
    _ledPin = ledPin;
}

void LEDController::handle() {
    // Si votre serveur web nécessite une gestion périodique, faites-le ici
}
