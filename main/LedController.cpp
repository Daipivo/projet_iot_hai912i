#include "HardwareSerial.h"
#include "LedController.h"

// Constructor 
LedController::LedController(int luminosityLedPin, int temperatureLedPin, AsyncWebServer* server)
    : _luminosityLedPin(luminosityLedPin), _temperatureLedPin(temperatureLedPin), _server(server), _isLuminosityLedOn(false), _isTemperatureLedOn(false) {}

// Init LED pins and server routes
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

    _server->on("/api/luminosityLed/status", HTTP_GET, [this](AsyncWebServerRequest* request){
        String status = _isLuminosityLedOn ? "On" : "Off";
        request->send(200, "text/plain; charset=utf-8", status);
    });
  
    _server->on("/api/temperatureLed/status", HTTP_GET, [this](AsyncWebServerRequest* request){
        String status = _isTemperatureLedOn ? "On" : "Off";
        request->send(200, "text/plain; charset=utf-8", status);
    });
}

// Turn on luminosity LED
void LedController::turnOnLuminosityLed() {
    digitalWrite(_luminosityLedPin, HIGH);
    _isLuminosityLedOn = true;
}

// Turn off luminosity LED
void LedController::turnOffLuminosityLed() {
    digitalWrite(_luminosityLedPin, LOW);
    _isLuminosityLedOn = false;
}

// Turn on temperature LED
void LedController::turnOnTemperatureLed() {
    digitalWrite(_temperatureLedPin, HIGH);
    _isTemperatureLedOn = true;
}

// Turn off temperature LED
void LedController::turnOffTemperatureLed() {
    digitalWrite(_temperatureLedPin, LOW);
    _isTemperatureLedOn = false;
}

// Check if luminosity LED is on
bool LedController::isLuminosityLedOn() {
    return _isLuminosityLedOn;
}

// Check if temperature LED is on
bool LedController::isTemperatureLedOn() {
    return _isTemperatureLedOn;
}

// Luminosity threshold event
void LedController::onSeuilLuminositeEvenement(bool estEnDessousSeuil) {
    estEnDessousSeuil ? turnOnLuminosityLed() : turnOffLuminosityLed();
}

// Temperature threshold event
void LedController::onSeuilTemperatureEvenement(bool estEnDessousSeuil) {
    estEnDessousSeuil ? turnOnTemperatureLed() : turnOffTemperatureLed();
}

// Toggle state luminosity LED
void LedController::toggleLuminosityLed() {
    if (_isLuminosityLedOn) {
        turnOffLuminosityLed();
    } else {
        turnOnLuminosityLed();
    }
}

// Toggle state temperature LED
void LedController::toggleTemperatureLed() {
    if (_isTemperatureLedOn) {
        turnOffTemperatureLed();
    } else {
        turnOnTemperatureLed();
    }
}

// Method call on event
void LedController::onEvenement(const String& typeEvenement, bool etat) {
    if (typeEvenement == "luminosite") {
        onSeuilLuminositeEvenement(etat);
    } else if (typeEvenement == "temperature") {
        onSeuilTemperatureEvenement(etat);
    }
}

// Handle periodic
void LedController::handle() {
}
