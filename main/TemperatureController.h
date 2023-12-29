#ifndef TEMPERATURECONTROLLER_H
#define TEMPERATURECONTROLLER_H

#include <Arduino.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include "GestionnaireEvenements.h"
#include <ArduinoJson.h>



class TemperatureController {
public:

    TemperatureController(int analogPin, AsyncWebServer* server, GestionnaireEvenements* gestionnaireEvenements);
    
    float getTemperature();
    void init();
    void handle();

private:
    GestionnaireEvenements* _gestionnaireEvenements;
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
