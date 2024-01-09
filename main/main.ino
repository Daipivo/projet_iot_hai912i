#include <WiFi.h>
#include <WiFiManager.h>
#include "DisplayManager.h"
#include <ESPAsyncWebServer.h>
#include <TFT_eSPI.h>
#include "TemperatureController.h"
#include "LuminosityController.h"
#include "LedController.h"
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
const int buttonDownPin = 0; // Bouton pour descendre dans la liste
const int buttonTogglePin = 35; // Bouton pour changer le statut de la LED
bool lastButtonDownState = LOW;
bool lastButtonToggleState = LOW;
unsigned long lastDebounceTime = 0;
const unsigned long debounceDelay = 50;

AsyncWebServer server(80);
EventManager eventManager;

// Create Controllers for routing
LedController ledController(luminosityLedPin, temperatureLedPin, &server);
TemperatureController temperatureController(temperaturePin, &server, &eventManager);
LuminosityController luminosityController(lumierePin, &server, &eventManager);

// Create Manager for display on ESP32
DisplayManager displayManager(tft, ledController, buttonDownPin, buttonTogglePin);

void setup() {
  Serial.begin(115200);

  // Init wifiManager
  WiFiManager wifiManager;
  wifiManager.autoConnect(ESP_NAME_CONNEXION);

  configTime(0, 0, ntpServer);

  // Getting IP Address
  IPAddress ip = WiFi.localIP();

  // Init Firebase
  FirebaseManager::getInstance().begin();
  FirebaseManager::getInstance().updateIpAddress(ROOM_LOCATION_ID, ip.toString());

  Serial.println("Démarrage du serveur sur le port 80");
  server.begin();
  Serial.println("Serveur démarré avec succès");
  
  eventManager.saveObserver("luminosite", &ledController);
  eventManager.saveObserver("temperature", &ledController);


  ledController.init();
  temperatureController.init();
  luminosityController.init();
  
  tft.init();
  tft.setRotation(0);
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.setTextSize(1.5);

  displayManager.init();
}

void loop() {
  temperatureController.handle();
  luminosityController.handle();
  ledController.handle();

  float temperature = temperatureController.getTemperature();
  float luminosite = luminosityController.getLuminosity();

  displayManager.updateDisplay(temperature, luminosite);

  displayManager.handleButtonLogic();
  
  delay(1000);
}
