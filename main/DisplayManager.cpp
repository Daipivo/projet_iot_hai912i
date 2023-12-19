#include "DisplayManager.h"

DisplayManager::DisplayManager(TFT_eSPI &tftDisplay) : tft(tftDisplay) {}

void DisplayManager::init() {
    tft.init();
    tft.setRotation(0);
    tft.fillScreen(TFT_BLACK);
    tft.setTextColor(TFT_WHITE, TFT_BLACK);
    tft.setTextSize(1.5);
}

void DisplayManager::updateDisplay(float temperature, float luminosite) {
    tft.fillScreen(TFT_BLACK);
    tft.setCursor(0, 0);
    tft.printf("Temp: %.2f C\n", temperature);
    tft.setCursor(0, 30);
    tft.printf("Lum: %.2f V", luminosite);
}
