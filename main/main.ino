#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <TFT_eSPI.h>
#include "WifiController.h"
#include "LEDController.h"

TFT_eSPI tft = TFT_eSPI();

AsyncWebServer server(80);

const int ledPin = 17;

const char* ssid = "ESP32-Yoann";
const char* password = "Esp32-Password";

WiFiController wifiController(ssid, password);
LEDController ledController;

void setup() {
    
    Serial.begin(115200);  // Initialiser le port série pour le débogage
    
    delay(1000); 
    
    Serial.println("Début du setup");
    
    wifiController.connect();

    Serial.println("Wifi connecté");

    ledController.init();

    Serial.println("LEDController initialisé");

    server.begin();

    Serial.println("Serveur démarré");
}

void loop() {
  ledController.handle();

}
