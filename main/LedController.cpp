#include "HardwareSerial.h"
#include "LedController.h"

LedController::LedController(int luminosityLedPin, int temperatureLedPin, AsyncWebServer* server)
    : _luminosityLedPin(luminosityLedPin), _temperatureLedPin(temperatureLedPin), _server(server), _isLuminosityLedOn(false), _isTemperatureLedOn(false) {}

void LedController::init() {
    pinMode(_luminosityLedPin, OUTPUT);
    pinMode(_temperatureLedPin, OUTPUT);

    _server->on("/api/luminosityLed", HTTP_PATCH, [this](AsyncWebServerRequest* request) {},
    NULL,
    [this](AsyncWebServerRequest* request, uint8_t* data, size_t len, size_t index, size_t total) {
        DynamicJsonDocument doc(128);
        deserializeJson(doc, (const char*)data);
        if (doc.containsKey("state")) {
            String state = doc["state"].as<String>(); 
            if (state == "on") {
                turnOnLuminosityLed();
                request->send(200, "text/plain; charset=utf-8", "Luminosity LED turned on");
            } else if (state == "off") {
                turnOffLuminosityLed();
                request->send(200, "text/plain; charset=utf-8", "Luminosity LED turned off");
            } else {
                request->send(400, "text/plain; charset=utf-8", "Invalid state");
            }
        } else {
            request->send(400, "text/plain; charset=utf-8", "State parameter is missing");
        }
    });

    // Endpoint pour changer l'état de la Temperature LED avec PATCH et corps de requête JSON
    _server->on("/api/temperatureLed", HTTP_PATCH, [this](AsyncWebServerRequest* request) {},
    NULL,
    [this](AsyncWebServerRequest* request, uint8_t* data, size_t len, size_t index, size_t total) {
        DynamicJsonDocument doc(128); 
        deserializeJson(doc, (const char*)data);
        if (doc.containsKey("state")) {
            String state = doc["state"].as<String>(); 
            if (state == "on") {
                turnOnTemperatureLed();
                request->send(200, "text/plain; charset=utf-8", "Temperature LED turned on");
            } else if (state == "off") {
                turnOffTemperatureLed();
                request->send(200, "text/plain; charset=utf-8", "Temperature LED turned off");
            } else {
                request->send(400, "text/plain; charset=utf-8", "Invalid state");
            }
        } else {
            request->send(400, "text/plain; charset=utf-8", "State parameter is missing");
        }
    });

    // Common status endpoint for both LEDs
    _server->on("/api/luminosityLed/status", HTTP_GET, [this](AsyncWebServerRequest* request){
        String status = _isLuminosityLedOn ? "On" : "Off";
        request->send(200, "text/plain; charset=utf-8", status);
    });
  
    _server->on("/api/temperatureLed/status", HTTP_GET, [this](AsyncWebServerRequest* request){
        String status = _isTemperatureLedOn ? "On" : "Off";
        request->send(200, "text/plain; charset=utf-8", status);
    });
}

void LedController::turnOnLuminosityLed() {
    digitalWrite(_luminosityLedPin, HIGH);
    _isLuminosityLedOn = true;
}

void LedController::turnOffLuminosityLed() {
    digitalWrite(_luminosityLedPin, LOW);
    _isLuminosityLedOn = false;
}

void LedController::turnOnTemperatureLed() {
    digitalWrite(_temperatureLedPin, HIGH);
    _isTemperatureLedOn = true;
}

void LedController::turnOffTemperatureLed() {
    digitalWrite(_temperatureLedPin, LOW);
    _isTemperatureLedOn = false;
}

// Implémentez les méthodes isLuminosityLedOn et isTemperatureLedOn
bool LedController::isLuminosityLedOn() {
    return _isLuminosityLedOn;
}

bool LedController::isTemperatureLedOn() {
    return _isTemperatureLedOn;
}

void LedController::onSeuilLuminositeEvenement(bool estEnDessousSeuil) {
    estEnDessousSeuil ? turnOnLuminosityLed() : turnOffLuminosityLed();
}

void LedController::onSeuilTemperatureEvenement(bool estEnDessousSeuil) {
    estEnDessousSeuil ? turnOnTemperatureLed() : turnOffTemperatureLed();
}

void LedController::toggleLuminosityLed() {
    if (_isLuminosityLedOn) {
        turnOffLuminosityLed();
    } else {
        turnOnLuminosityLed();
    }
}

void LedController::toggleTemperatureLed() {
    if (_isTemperatureLedOn) {
        turnOffTemperatureLed();
    } else {
        turnOnTemperatureLed();
    }
}

void LedController::onEvenement(const String& typeEvenement, bool etat) {
    if (typeEvenement == "luminosite") {
        onSeuilLuminositeEvenement(etat);
    } else if (typeEvenement == "temperature") {
        onSeuilTemperatureEvenement(etat);
    }
}

void LedController::handle() {
    // Logique de mise à jour ou de vérification périodique, si nécessaire
}
