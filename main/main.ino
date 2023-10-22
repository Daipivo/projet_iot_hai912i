#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <TFT_eSPI.h>
#include "WifiController.h"
#include "LEDController.h"
#include "TEMPERATUREController.h"
#include "LUMIEREController.h" 

TFT_eSPI tft = TFT_eSPI();

const int ledPin = 17;
const int temperaturePin = 32;
const int lumierePin = 33; 

const char* ssid = "ESP32-Yoann";
const char* password = "Esp32-Password";

AsyncWebServer server(80);
WiFiController wifiController(ssid, password);
TEMPERATUREController temperatureController(temperaturePin, &server);
LEDController ledController(ledPin, &server);
LUMIEREController lumiereController(lumierePin, &server);

void setup() {
    
    Serial.begin(115200);  // Initialiser le port série pour le débogage

    server.begin();

    pinMode(ledPin, OUTPUT);
    
    delay(1000); 
    
    Serial.println("Début du setup");
    
    wifiController.connect();

    Serial.println("Wifi connecté");

    ledController.init();
    Serial.println("Controlleur de led initialisé !");

    temperatureController.init();
    Serial.println(temperatureController.getCurrentTemperature());
    Serial.println("Controlleur de température initialisé !");

    lumiereController.init();
    Serial.println("Controlleur de lumière initialisé !");

    Serial.println("Serveur démarré");
}

void loop() {

  ledController.handle();
  temperatureController.handle();
  lumiereController.handle();

}
