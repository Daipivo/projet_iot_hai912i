#ifndef LuminosityController_H
#define LuminosityController_H

#include <Arduino.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include "EventManager.h"
#include <ArduinoJson.h>

class LuminosityController {
public:
    LuminosityController(int analogPin, AsyncWebServer* server, EventManager* eventManager);
    
    float getLuminosity();
    void init();
    void handle();

private:
    EventManager* _eventManager;
    bool _luminosityControlEnabled = false;
    float _luminosityThreshold = 0.0;
    int _analogPin;
    AsyncWebServer* _server;
};

#endif // LuminosityController_H
