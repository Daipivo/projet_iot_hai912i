#include "DisplayManager.h"
#include <TFT_eSPI.h>

DisplayManager::DisplayManager(TFT_eSPI &tftDisplay, LedController& ledCtrl, int downPin, int togglePin) 
    : tft(tftDisplay), ledController(ledCtrl), _buttonDownPin(downPin), _buttonTogglePin(togglePin), selectedLed(1), lastButtonDownState(LOW), lastButtonToggleState(LOW), lastDebounceTime(0) {}

void DisplayManager::init() {
    pinMode(_buttonDownPin, INPUT_PULLUP);
    pinMode(_buttonTogglePin, INPUT_PULLUP);

    tft.init();
    tft.setRotation(0);
    tft.fillScreen(TFT_BLACK);
    tft.setTextColor(TFT_WHITE, TFT_BLACK);
    tft.setTextSize(1.5);
}

void DisplayManager::updateDisplay(float temperature, float luminosite) {
    tft.fillScreen(TFT_BLACK);
    tft.setCursor(0, 0);

    // Affichage de l'état de la LED de température
    tft.setTextColor(selectedLed == 2 ? TFT_YELLOW : TFT_WHITE, TFT_BLACK);
    tft.printf("LED Temperature : %s\n", ledController.isTemperatureLedOn() ? "ON" : "OFF");

    // Affichage de l'état de la LED de luminosité
    tft.setTextColor(selectedLed == 1 ? TFT_YELLOW : TFT_WHITE, TFT_BLACK);
    tft.setCursor(0, 30);
    tft.printf("LED Luminosite : %s\n", ledController.isLuminosityLedOn() ? "ON" : "OFF");

    // Affichage des valeurs de température et luminosité
    tft.setTextColor(TFT_WHITE, TFT_BLACK);
    tft.setCursor(0, 60);
    tft.printf("Temperature : %.2f C\n", temperature);
    tft.setCursor(0, 90);
    tft.printf("Luminosite : %.2f V", luminosite);
}

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
