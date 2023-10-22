#ifndef LEDController_h
#define LEDController_h

#include <ESPAsyncWebServer.h>

class LEDController {
public:
    LEDController(int analogPin, AsyncWebServer *server);
    void init();  // Cette méthode initialise le serveur web
    void handle();  // Cette méthode gère les requêtes entrantes, si nécessaire
private:
    AsyncWebServer *_server;
    int _analogPin;
};

#endif
