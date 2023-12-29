#ifndef LUMIERECONTROLLER_H
#define LUMIERECONTROLLER_H

#include <Arduino.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include "GestionnaireEvenements.h"
#include <ArduinoJson.h>

class LumiereController {
public:
    LumiereController(int analogPin, AsyncWebServer* server, GestionnaireEvenements* gestionnaireEvenements);
    
    float getLuminosity();
    void init();
    void handle();

private:
    GestionnaireEvenements* _gestionnaireEvenements;
    bool _luminosityControlEnabled = false;
    float _luminosityThreshold = 0.0;
    int _analogPin;
    AsyncWebServer* _server;
};

#endif // LUMIERECONTROLLER_H
