#ifndef TEMPERATURECONTROLLER_H
#define TEMPERATURECONTROLLER_H

#include <Arduino.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include "EventManager.h"
#include <ArduinoJson.h>


// Init class
class TemperatureController {

// Public methods
public:

    TemperatureController(int analogPin, AsyncWebServer* server, EventManager* eventManager);
    
    float getTemperature();
    void init();
    void handle();

// Private attributes
private:
    EventManager* _eventManager;
    bool _temperatureControlEnabled = false;
    float _temperatureThreshold = 0.0;
    int _analogPin;
    AsyncWebServer* _server;
    static const float R1;
    static const float T0;
    static const float R0;
    static const float B;
};

#endif // TEMPERATURECONTROLLER_H
