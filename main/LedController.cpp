#include "LedController.h"

LedController::LedController(int analogPin, AsyncWebServer* server) 
    : _analogPin(analogPin), _server(server) {}

void LedController::init() {

    pinMode(_analogPin, OUTPUT);

    _server->on("/led/on", HTTP_GET, [this](AsyncWebServerRequest* request){
        turnOnLed();
        request->send(200, "text/plain; charset=utf-8", "LED allumée");
    });

    _server->on("/led/off", HTTP_GET, [this](AsyncWebServerRequest* request){
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

void LedController::onSeuilLuminositeEvenement(bool estEnDessousSeuil) {
    estEnDessousSeuil ? turnOnLed() : turnOffLed();
}

void LedController::onSeuilTemperatureEvenement(bool estEnDessousSeuil) {
    estEnDessousSeuil ? turnOffLed() : turnOnLed();
}

void LedController::onEvenement(const String& typeEvenement, bool etat) {
  
    if (typeEvenement == "luminosite") {
      onSeuilLuminositeEvenement(etat);
    } else {
      onSeuilTemperatureEvenement(etat);
    }
    
}


void LedController::handle() {
    
}
