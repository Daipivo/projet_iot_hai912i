#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <TFT_eSPI.h>
#include "WifiController.h"
#include "TemperatureController.h"
#include "LumiereController.h"
#include "LedController.h"
#include "DisplayManager.h"
#include <Firebase_ESP_Client.h>
#include <Wire.h>
#include "time.h"
#include "addons/TokenHelper.h"
// Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"

#define API_KEY "AIzaSyD9FWJKrJF7q93V1H0V0vdk8jVjD2Dr6CI"

// Définissez le SSID et le mot de passe de votre point d'accès
const char* ap_ssid = "ESP32-AccessPoint";
const char* ap_password = "123456789";

// Informations de connexion pour votre réseau Wi-Fi (STA)
const char* sta_ssid = "Livebox-bibou";
const char* sta_password = "camilleyoann_3457";

#define USER_EMAIL "yoann.reyne@gmail.com"
#define USER_PASSWORD "Mhsc34660"

#define FIREBASE_PROJECT_ID "iotprojectdatabase"

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

String uid;

String databasePath;
// Database child nodes
String tempPath = "/temperature";
String humPath = "/luminosity";

String parentPath;

int timestamp;
FirebaseJson json;

const char* ntpServer = "pool.ntp.org";

unsigned long sendDataPrevMillis = 0;
unsigned long timerDelay = 180000;

unsigned long getTime() {
  time_t now;
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    //Serial.println("Failed to obtain time");
    return(0);
  }
  time(&now);
  return now;
}

TFT_eSPI tft = TFT_eSPI();

const int temperaturePin = 33;
const int lumierePin = 32;
const int luminosityLedPin = 17;
const int temperatureLedPin = 15;

AsyncWebServer server(80);
GestionnaireEvenements gestionnaireEvenements;
WifiController wifiController(ap_ssid, ap_password, sta_ssid, sta_password);
LedController ledController(luminosityLedPin, temperatureLedPin, &server);
TemperatureController temperatureController(temperaturePin, &server, &gestionnaireEvenements);
LumiereController lumiereController(lumierePin, &server, &gestionnaireEvenements);
DisplayManager displayManager(tft);

void setup() {
  
  Serial.begin(115200);

  // Configurer l'ESP32 en mode point d'accès
  
  wifiController.connect();
  configTime(0, 0, ntpServer);

  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the user sign in credentials */
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  
  config.token_status_callback = tokenStatusCallback;
  Serial.println(fbdo.errorReason());

  Firebase.reconnectNetwork(true);
  fbdo.setBSSLBufferSize(4096 /* Rx buffer size in bytes from 512 - 16384 */, 1024 /* Tx buffer size in bytes from 512 - 16384 */);

  fbdo.setResponseSize(2048);
  // Initialize the library with the Firebase authen and config
  Firebase.begin(&config, &auth);
  Serial.println(fbdo.errorReason());


  Serial.println("Getting User UID");
  while ((auth.token.uid) == "") {
    Serial.print('.');
    delay(1000);
  }
  // Print user UID
  uid = auth.token.uid.c_str();
  Serial.print("User UID: ");
  Serial.println(uid);

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

  float temperature = temperatureController.getTemperature();
  Serial.print("Température initiale: ");
  Serial.print(temperature);
  Serial.println(" °C");
  
  displayManager.init();

}

void loop() {



  temperatureController.handle();
  lumiereController.handle();
  ledController.handle();
  float temperature = temperatureController.getTemperature();
  float luminosite = lumiereController.getLuminosity();

  if (Firebase.ready() && (millis() - sendDataPrevMillis > timerDelay || sendDataPrevMillis == 0)) {
    sendDataPrevMillis = millis();

    // Lecture des données des capteurs
    float temperature = temperatureController.getTemperature();
    // Vous pouvez également ajouter d'autres lectures de capteurs ici
    
    // Création de l'objet FirebaseJson
    FirebaseJson content;

    // Ajout des données au JSON, correspondant aux champs de votre document Firestore
    content.set("fields/isAutomatic/booleanValue", false); // Mettez à jour cette valeur comme nécessaire
    content.set("fields/isLedOn/booleanValue", false);     // Mettez à jour cette valeur comme nécessaire
    content.set("fields/threshold/integerValue", "4");     // Mettez à jour cette valeur comme nécessaire
    content.set("fields/value/doubleValue", temperature);  // Valeur de température réelle

    String documentUID = String(millis());

    // Chemin du document Firestore où stocker les données
    String documentPath = "temperature/" + documentUID; 
    
    if (Firebase.Firestore.createDocument(&fbdo, FIREBASE_PROJECT_ID, "" /* databaseId can be (default) or empty */, documentPath.c_str(), content.raw()))
        Serial.printf("ok\n%s\n\n", fbdo.payload().c_str());
    else
        Serial.println(fbdo.errorReason());
  }
  

  displayManager.updateDisplay(temperature, luminosite);

  delay(1000);
}

