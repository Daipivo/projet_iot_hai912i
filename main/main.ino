#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <TFT_eSPI.h>
#include "WifiManager.h"
#include "TemperatureController.h"
#include "LumiereController.h"
#include "LedController.h"
#include "DisplayManager.h"
#include "FirebaseManager.h" 
#include <Wire.h>
#include "time.h"
#include "addons/TokenHelper.h"
#include "Config.h"

const char* ntpServer = "pool.ntp.org";

TFT_eSPI tft = TFT_eSPI();
const int temperaturePin = 33;
const int lumierePin = 32;
const int luminosityLedPin = 17;
const int temperatureLedPin = 15;

AsyncWebServer server(80);
GestionnaireEvenements gestionnaireEvenements;

// Création des instances de contrôleurs
WifiManager wifiManager(STA_SSID, STA_PASSWORD);
LedController ledController(luminosityLedPin, temperatureLedPin, &server);
TemperatureController temperatureController(temperaturePin, &server, &gestionnaireEvenements);
LumiereController lumiereController(lumierePin, &server, &gestionnaireEvenements);
DisplayManager displayManager(tft);

void setup() {
  Serial.begin(115200);
  
  configTime(0, 0, ntpServer);
  wifiManager.connect();

  // Initialisation de Firebase
  FirebaseManager::getInstance().begin();
  FirebaseManager::getInstance().updateIpAddress(ROOM_LOCATION_ID, wifiManager.getLocalIP().toString());

  Serial.println("Démarrage du serveur sur le port 80");
  server.begin();
  Serial.println("Serveur démarré avec succès");

  gestionnaireEvenements.enregistrerObservateur("luminosite", &ledController);
  gestionnaireEvenements.enregistrerObservateur("temperature", &ledController);

  ledController.init();
  temperatureController.init();
  lumiereController.init();
  
  tft.init();
  tft.setRotation(0);
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.setTextSize(1.5);

  displayManager.init();
}

void loop() {
  temperatureController.handle();
  lumiereController.handle();
  ledController.handle();

  float temperature = temperatureController.getTemperature();
  float luminosite = lumiereController.getLuminosity();

  displayManager.updateDisplay(temperature, luminosite);

  delay(1000);  // À utiliser avec prudence, peut-être remplacé par une gestion du temps non bloquante
}
