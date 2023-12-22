#include "LedController.h"

LedController::LedController(int analogPin, AsyncWebServer* server) 
    : _analogPin(analogPin), _server(server) {}

void LedController::init() {

    pinMode(_analogPin, OUTPUT);

    _server->on("/led/on", HTTP_GET, [this](AsyncWebServerRequest* request){
        _controlManuelActif = true;
        _derniereActionManuelle = millis();
        turnOnLed();
        request->send(200, "text/plain; charset=utf-8", "LED allumée");
    });

    _server->on("/led/off", HTTP_GET, [this](AsyncWebServerRequest* request){
        _controlManuelActif = true;
        _derniereActionManuelle = millis();
        turnOffLed();
        request->send(200, "text/plain; charset=utf-8", "LED éteinte");
    });
    
}

void LedController::turnOnLed() {
    digitalWrite(_analogPin, HIGH);
}

void LedController::turnOffLed() {
    digitalWrite(_analogPin, LOW);
}

void LedController::onEvenement(const String& typeEvenement, bool estEnDessousSeuil) {
    if (!_controlManuelActif) {
      if (typeEvenement == "luminosite") {
          estEnDessousSeuil ? turnOnLed() : turnOffLed();
      }
      else{
          estEnDessousSeuil ? turnOffLed() : turnOnLed();
      }
    }
}


void LedController::handle() {
    if (_controlManuelActif && (millis() - _derniereActionManuelle > _delaiControlManuel)) {
        _controlManuelActif = false;  // Réinitialiser le contrôle manuel après le délai
    }
}
