#ifndef LedController_H
#define LedController_H

#include <ESPAsyncWebServer.h>
#include "IEventObserver.h" 

class LedController : public IEventObserver {
public:
    LedController(int luminosityLedPin, int temperatureLedPin, AsyncWebServer* server);
    void init();  
    void handle();
    void turnOnLuminosityLed();
    void turnOffLuminosityLed();
    void turnOnTemperatureLed();
    void turnOffTemperatureLed();
    bool isLuminosityLedOn();
    bool isTemperatureLedOn();
    void onSeuilLuminositeEvenement(bool estEnDessousSeuil);
    void onSeuilTemperatureEvenement(bool estEnDessousSeuil);
    void onEvenement(const String& typeEvenement, bool etat) override;
    void toggleLuminosityLed();
    void toggleTemperatureLed();

private:
    AsyncWebServer* _server;
    int _luminosityLedPin;
    int _temperatureLedPin;
    bool _isLuminosityLedOn;
    bool _isTemperatureLedOn;
};

#endif // LedController_H
