#ifndef LedController_H
#define LedController_H

#include <ESPAsyncWebServer.h>

class LedController {
public:
    LedController(int analogPin, AsyncWebServer& server);
    void init();  // Cette méthode initialise le serveur web
    void handle();  // Cette méthode gère les requêtes entrantes, si nécessaire
private:
    AsyncWebServer& _server;
    int _analogPin;
};

#endif
