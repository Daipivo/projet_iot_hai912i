#ifndef TEMPERATURE_CONTROLLER_H
#define TEMPERATURE_CONTROLLER_H

#include <Arduino.h>
#include <ESPAsyncWebServer.h> 

class TEMPERATUREController {
public:
    TEMPERATUREController(int analogPin, AsyncWebServer& server);
    void handle();
    void init();
    
private:
    int _analogPin;
    AsyncWebServer& _server;
    float getTemperature();
    static const float R1;
    static const float T1;
    static const float R0;
    static const float B;
};

#endif
