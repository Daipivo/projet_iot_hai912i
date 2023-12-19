#ifndef DISPLAYMANAGER_H
#define DISPLAYMANAGER_H

class DisplayManager {
public:
    DisplayManager(TFT_eSPI &tftDisplay);
    void init();
    void updateDisplay(float temperature, float luminosite);

private:
    TFT_eSPI &tft;
};

#endif