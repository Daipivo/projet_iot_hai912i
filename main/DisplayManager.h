#ifndef DISPLAYMANAGER_H
#define DISPLAYMANAGER_H

#include <TFT_eSPI.h>
#include <WiFiManager.h>
#include "LedController.h"

class DisplayManager {
private:
    TFT_eSPI& tft;
    LedController& ledController;
    int selectedLed;
    int _buttonDownPin;
    int _buttonTogglePin;
    bool lastButtonDownState;
    bool lastButtonToggleState;
    unsigned long lastDebounceTime;
    const unsigned long debounceDelay = 50;

public:
    DisplayManager(TFT_eSPI &tftDisplay, LedController& ledCtrl, int downPin, int togglePin);
    void init();
    void updateDisplay(float temperature, float luminosite, float heapUsage, float memoryFlashUsage);
    void handleButtonPress(int buttonPin);
    void handleButtonLogic();  // Nouvelle méthode
};


#endif // DISPLAYMANAGER_H
