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
    bool isLedOn();
    void onSeuilLuminositeEvenement(bool estEnDessousSeuil);
    void onSeuilTemperatureEvenement(bool estEnDessousSeuil);
    void onEvenement(const String& typeEvenement, bool etat) override;

private:
    AsyncWebServer* _server;
    int _analogPin;
    bool _isLedOn;
};

#endif // LedController_H
