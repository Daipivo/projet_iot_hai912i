#ifndef LedController_H
#define LedController_H

#include <ESPAsyncWebServer.h>
#include "IEvenementObservateur.h" 

class LedController : public IEvenementObservateur {
public:
    
    LedController(int analogPin, AsyncWebServer* server);
    void init();  
    void handle();
    void turnOnLed();
    void turnOffLed();
    void onEvenement(const String& typeEvenement, bool estEnDessousSeuil) override;

private:
    bool _controlManuelActif = false;
    unsigned long _derniereActionManuelle = 0;
    const unsigned long _delaiControlManuel = 10000; 
    AsyncWebServer* _server;
    int _analogPin;
};

#endif // LedController_H
