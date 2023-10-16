#ifndef WebController_h
#define WebController_h

#include <ESPAsyncWebServer.h>

class WebController {
public:
    WebController();
    void init();  // Cette méthode initialise le serveur web
    void handle();  // Cette méthode gère les requêtes entrantes, si nécessaire
    void setLedPin(int ledPin);
private:
    AsyncWebServer server;
    int _ledPin;
};

#endif
