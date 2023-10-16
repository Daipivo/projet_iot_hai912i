#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <TFT_eSPI.h>
#include "../controller/WiFiController.h"
#include "../controller/WebController.h"

TFT_eSPI tft = TFT_eSPI();

AsyncWebServer server(80);

const int ledPin = 17;

const char* ssid = "nomreseau";
const char* password = "mdpreseau";

WiFiController wifiController(ssid, password);

void setup() {
    
    wifiController.connect();

    webController.setLedPin(ledPin);
    webController.init();

    pinMode(ledPin, OUTPUT);

    server.begin();
}

void loop() {
  webController.handle();

}
