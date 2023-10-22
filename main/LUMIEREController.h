#ifndef LUMIERECONTROLLER_H
#define LUMIERECONTROLLER_H

#include <Arduino.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>

class LUMIEREController {
public:
    LUMIEREController(int analogPin, AsyncWebServer* server);
    
    float getLuminosity();
    void init();
    void handle();

private:
    int _analogPin;
    AsyncWebServer* _server;
};

#endif // LUMIERECONTROLLER_H
