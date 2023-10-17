#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <TFT_eSPI.h>
#include "WifiController.h"
#include "LEDController.h"
#include "TEMPERATUREController.h"

TFT_eSPI tft = TFT_eSPI();

const int ledPin = 17;
const int temperaturePin = 12; 

const char* ssid = "ESP32-Yoann";
const char* password = "Esp32-Password";

AsyncWebServer server(80);
WiFiController wifiController(ssid, password);
//TEMPERATUREController temperatureController(temperaturePin, server);
LEDController ledController;

void setup() {
    
    Serial.begin(115200);  // Initialiser le port série pour le débogage

    pinMode(ledPin, OUTPUT);
    
    delay(1000); 
    
    Serial.println("Début du setup");
    
    wifiController.connect();

    Serial.println("Wifi connecté");

    ledController.init();
    ledController.setLedPin(ledPin);
    Serial.println("LEDController initialisé");

    //temperatureController.init();
    Serial.println("TEMPERATUREController initialisé");


    server.begin();

    Serial.println("Serveur démarré");
}

void loop() {
  ledController.handle();
  //temperatureController.handle();
}
