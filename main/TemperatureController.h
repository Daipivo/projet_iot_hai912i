#ifndef TEMPERATURECONTROLLER_H
#define TEMPERATURECONTROLLER_H

#include <Arduino.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>

class TemperatureController {
public:
    TemperatureController(int analogPin, AsyncWebServer* server);
    
    float getTemperature();
    void init();
    void handle();

private:
    int _analogPin;
    AsyncWebServer* _server;
    static const float R1;
    static const float T0;
    static const float R0;
    static const float B;
};

#endif // TEMPERATURECONTROLLER_H
