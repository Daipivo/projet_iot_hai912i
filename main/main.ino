#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <TFT_eSPI.h>
#include "WifiController.h"
#include "TEMPERATUREController.h"
#include "LUMIEREController.h"
#include "LEDController.h"

// Définissez le SSID et le mot de passe de votre point d'accès
const char* ssid = "ESP32-AccessPoint";
const char* password = "123456789";

TFT_eSPI tft = TFT_eSPI();

const int temperaturePin = 32;
const int lumierePin = 33;
const int transistorLedPin = 17;

AsyncWebServer server(80);
WiFiController wifiController(ssid, password);
LEDController ledController(transistorLedPin, &server);
TEMPERATUREController temperatureController(temperaturePin, &server);
LUMIEREController lumiereController(lumierePin, &server);

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

  tft.init();
  tft.setRotation(0);
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.setTextSize(1.5);
  updateDisplay();

}

void updateDisplay() {
  // Obtenir les données de température et de luminosité
  float temperature = temperatureController.getTemperature();
  float luminosite = lumiereController.getLuminosity();

  // Effacer l'écran et afficher les nouvelles valeurs
  tft.fillScreen(TFT_BLACK);
  tft.setCursor(0, 0);
  tft.printf("Temp: %.2f C\n", temperature);
  tft.setCursor(0, 30);
  tft.printf("Lum: %.2f V", luminosite);
}

void loop() {
  updateDisplay(); // Mettre à jour l'affichage
  delay(1000);
}
