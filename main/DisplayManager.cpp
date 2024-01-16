#include "DisplayManager.h"
#include <TFT_eSPI.h>


// Constructor
DisplayManager::DisplayManager(TFT_eSPI &tftDisplay, LedController& ledCtrl, int downPin, int togglePin) 
    : tft(tftDisplay), ledController(ledCtrl), _buttonDownPin(downPin), _buttonTogglePin(togglePin), selectedLed(1), lastButtonDownState(LOW), lastButtonToggleState(LOW), lastDebounceTime(0) {}

// Init
void DisplayManager::init() {
    
    pinMode(_buttonDownPin, INPUT_PULLUP);
    pinMode(_buttonTogglePin, INPUT_PULLUP);

    tft.init();
    tft.setRotation(0);
    tft.fillScreen(TFT_BLACK);
    tft.setTextColor(TFT_WHITE, TFT_BLACK);
    tft.setTextSize(1.5);
}

// Update display with attributes
void DisplayManager::updateDisplay(float temperature, float luminosite, float heapUsage, float memoryFlashUsage) {
    tft.fillScreen(TFT_BLACK);
    tft.setCursor(0, 0);

    // Add temperature LED display
    tft.setTextColor(selectedLed == 2 ? TFT_YELLOW : TFT_WHITE, TFT_BLACK);
    tft.printf("Temperature LED : %s\n", ledController.isTemperatureLedOn() ? "ON" : "OFF");

    // Add luminosity LED display
    tft.setTextColor(selectedLed == 1 ? TFT_YELLOW : TFT_WHITE, TFT_BLACK);
    tft.setCursor(0, 30);
    tft.printf("Luminosity LED : %s\n", ledController.isLuminosityLedOn() ? "ON" : "OFF");

    // Add sensor values 
    tft.setTextColor(TFT_WHITE, TFT_BLACK);
    tft.setCursor(0, 60);
    tft.printf("Temperature : %.2f C\n", temperature);
    tft.setCursor(0, 90);
    tft.printf("Luminosity : %.2f V", luminosite);

    tft.setTextColor(TFT_WHITE, TFT_BLACK);
    tft.setCursor(0, 120);
    tft.printf("Heap mem.: %.2f%%", heapUsage);

    tft.setTextColor(TFT_WHITE, TFT_BLACK);
    tft.setCursor(0, 150);
    tft.printf("Flash mem. : %.2f%%", memoryFlashUsage);
}

// Handle button action
void DisplayManager::handleButtonPress(int buttonPin) {
    if (buttonPin == _buttonDownPin) {
        selectedLed = (selectedLed % 2) + 1;
    } else if (buttonPin == _buttonTogglePin) {
        switch(selectedLed) {
            case 1:
                ledController.toggleLuminosityLed();
                break;
            case 2:
                ledController.toggleTemperatureLed();
                break;
        }
    }
}

// Handle button logic
void DisplayManager::handleButtonLogic() {
    bool currentButtonDownState = digitalRead(_buttonDownPin) == LOW;
    bool currentButtonToggleState = digitalRead(_buttonTogglePin) == LOW;

    if (currentButtonDownState != lastButtonDownState && millis() - lastDebounceTime > debounceDelay) {
        if (currentButtonDownState) {
            handleButtonPress(_buttonDownPin);
        }
        lastDebounceTime = millis();
    }

    else if (currentButtonToggleState != lastButtonToggleState && millis() - lastDebounceTime > debounceDelay) {
        if (currentButtonToggleState) {
            handleButtonPress(_buttonTogglePin);
        }
        lastDebounceTime = millis();
    }

    else if (currentButtonDownState && currentButtonToggleState) {
        Serial.println("Réinitialisation des paramètres Wi-Fi...");
        WiFiManager wifiManager;
        wifiManager.resetSettings();
        ESP.restart();
    }

    lastButtonDownState = currentButtonDownState;
    lastButtonToggleState = currentButtonToggleState;
}
