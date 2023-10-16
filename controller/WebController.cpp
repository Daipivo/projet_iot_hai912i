#include "WebController.h"

WebController::WebController() : server(80) {}

void WebController::init() {

    server.on("/route1", HTTP_GET, [](AsyncWebServerRequest *request) {
        // Traitement pour la route1
    });

    server.on("/allumeLed", HTTP_GET, [this](AsyncWebServerRequest *request){
    digitalWrite(_ledPin, HIGH);
    request->send(200, "text/plain", "LED allumée");
});

    // Ajoutez d'autres routes si nécessaire

    server.begin();  // Démarre le serveur web
}

void WebController::setLedPin(int ledPin) {
    _ledPin = ledPin;
}

void WebController::handle() {
    // Si votre serveur web nécessite une gestion périodique, faites-le ici
}
