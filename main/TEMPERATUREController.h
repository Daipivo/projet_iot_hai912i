#ifndef TEMPERATURE_CONTROLLER_H
#define TEMPERATURE_CONTROLLER_H

#include <Arduino.h>
#include <ESPAsyncWebServer.h> 

class TEMPERATUREController {
public:
    TEMPERATUREController(int analogPin, AsyncWebServer* server);
    void handle();
    void init();
    float getTemperature();
    
private:
    int _analogPin;
    AsyncWebServer* _server;
    static const float R1;
    static const float T0; 
    static const float R0;
    static const float B;
};

#endif
