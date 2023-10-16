#include "WifiController.h"

WiFiController::WiFiController(const char* ssid, const char* password) : _ssid(ssid), _password(password) {}

void WiFiController::connect() {
    Serial.println("\nDémarrage du Point d'Accès Wi-Fi...");

    WiFi.mode(WIFI_AP);
    WiFi.softAP(_ssid, _password); 

    Serial.println("Point d'Accès Wi-Fi démarré avec succès!");
    Serial.print("Adresse IP du Point d'Accès: ");
    Serial.println(WiFi.softAPIP());
}

bool WiFiController::isConnected() {
    return WiFi.status() == WL_CONNECTED;
}

IPAddress WiFiController::getLocalIP() {
    return WiFi.localIP();
}
