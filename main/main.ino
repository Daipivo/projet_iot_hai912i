#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <TFT_eSPI.h>
#include "WifiController.h"
#include "TemperatureController.h"
#include "LumiereController.h"
#include "LedController.h"
#include "DisplayManager.h"


// Définissez le SSID et le mot de passe de votre point d'accès
const char* ssid = "ESP32-AccessPoint";
const char* password = "123456789";

TFT_eSPI tft = TFT_eSPI();

const int temperaturePin = 32;
const int lumierePin = 33;
const int transistorLedPin = 17;

AsyncWebServer server(80);
WiFiController wifiController(ssid, password);
LedController ledController(transistorLedPin, server);
TemperatureController temperatureController(temperaturePin, server);
LumiereController lumiereController(lumierePin, server);
DisplayManager displayManager(tft);

void setup() {
  Serial.begin(115200);

  // Configurer l'ESP32 en mode point d'accès
  wifiController.connect();

  Serial.println("Démarrage du serveur sur le port 80");
  server.begin();
  Serial.println("Serveur démarré avec succès");

  temperatureController.init();
  lumiereController.init();
  ledController.init();
  displayManager.init();

}

void loop() {

  float temperature = temperatureController.getTemperature();
  float luminosite = lumiereController.getLuminosity();
  
  displayManager.updateDisplay(temperature, luminosite);

  delay(1000);
}
