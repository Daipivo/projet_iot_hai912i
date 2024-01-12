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
#include "MemoryManager.h"


const char* ntpServer = "pool.ntp.org";

TFT_eSPI tft = TFT_eSPI();

// Pin for temperature sensor
const int temperaturePin = 33;

// Pin for luminosity sensor
const int luminosityPin = 32;

// Pin for temperature LED
const int temperatureLedPin = 15;

// Pin for luminosity LED
const int luminosityLedPin = 17;

// Pin for down button
const int buttonDownPin = 0; 

// Pin for toggle button
const int buttonTogglePin = 35; 

// Last state of the down button
bool lastButtonDownState = LOW;

// Last state of the toggle button
bool lastButtonToggleState = LOW;

// Create web server on port 80
AsyncWebServer server(80);

// Initialize manager for events
EventManager eventManager;
MemoryManager memoryManager;

// Initialize controllers for routing
LedController ledController(luminosityLedPin, temperatureLedPin, &server);
TemperatureController temperatureController(temperaturePin, &server, &eventManager);
LuminosityController luminosityController(luminosityPin, &server, &eventManager);

// Initialize manager for display
DisplayManager displayManager(tft, ledController, buttonDownPin, buttonTogglePin);

// Initialize wifi manager
WiFiManager wifiManager;

void setup() {
  Serial.begin(115200);

  // Init wifiManager
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

  // Initialize the controllers
  ledController.init();
  temperatureController.init();
  luminosityController.init();

  memoryManager.updateMemoryUsage();
  
  // Initialize the TFT display
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

  // Get temperature and luminosity values
  float temperature = temperatureController.getTemperature();
  float luminosity = luminosityController.getLuminosity();
  float heapUsage = memoryManager.getHeapUsagePercentage();
  float memoryFlashUsage = memoryManager.getFlashMemoryUsage();

  // Update sensor values
  displayManager.updateDisplay(temperature, luminosity, heapUsage, memoryFlashUsage);

  // Handle buttons
  displayManager.handleButtonLogic();

  memoryManager.updateMemoryUsage(); 
  
  delay(1000);

}
