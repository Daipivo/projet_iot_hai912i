#include "HardwareSerial.h"
#include "LedController.h"

LedController::LedController(int analogPin, AsyncWebServer* server) 
    : _analogPin(analogPin), _server(server), _isLedOn(false) {}

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

     _server->on("/led/status", HTTP_GET, [this](AsyncWebServerRequest* request){
        String status = _isLedOn ? "LED allumée" : "LED éteinte";
        request->send(200, "text/plain; charset=utf-8", status);
    });
    
}

bool LedController::isLedOn() {
    return _isLedOn;
}

void LedController::turnOnLed() {
    if (!_isLedOn) {
        digitalWrite(_analogPin, HIGH);
        _isLedOn = true;
    }
}

void LedController::turnOffLed() {
    if (_isLedOn) {
        digitalWrite(_analogPin, LOW);
        _isLedOn = false;
    }
}


void LedController::onSeuilLuminositeEvenement(bool estEnDessousSeuil) {
    
    estEnDessousSeuil ? turnOnLed() : turnOffLed();
}

void LedController::onSeuilTemperatureEvenement(bool estEnDessousSeuil) {
    estEnDessousSeuil ? turnOffLed() : turnOnLed();
}

void LedController::onEvenement(const String& typeEvenement, bool etat) {
  
    // Priorité à la luminosité
    if (typeEvenement == "luminosite") {
        onSeuilLuminositeEvenement(etat);
    } else {  // La température ne change l'état de la LED que si la luminosité n'a pas déjà allumé la LED
        onSeuilTemperatureEvenement(etat);
    }
}



void LedController::handle() {
    
}
