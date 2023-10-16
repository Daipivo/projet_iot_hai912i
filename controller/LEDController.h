#ifndef LEDController_h
#define LEDController_h

#include <ESPAsyncWebServer.h>

class LEDController {
public:
    LEDController();
    void init();  // Cette méthode initialise le serveur web
    void handle();  // Cette méthode gère les requêtes entrantes, si nécessaire
    void setLedPin(int ledPin);
private:
    AsyncWebServer server;
    int _ledPin;
};

#endif
