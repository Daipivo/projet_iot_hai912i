#include "WifiController.h"

WifiController::WifiController(const char* ap_ssid, const char* ap_password, const char* sta_ssid, const char* sta_password) 
: _ap_ssid(ap_ssid), _ap_password(ap_password), _sta_ssid(sta_ssid), _sta_password(sta_password) {}

void WifiController::connect() {
    Serial.println("\nDémarrage du Point d'Accès Wi-Fi...");

    WiFi.mode(WIFI_AP_STA); // Mode AP+STA
    WiFi.softAP(_ap_ssid, _ap_password); // Configurer en tant que Point d'Accès
    WiFi.begin(_sta_ssid, _sta_password); // Se connecter au réseau Wi-Fi

    // Attendre la connexion au réseau Wi-Fi
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }

    Serial.println("\nConnecté au réseau Wi-Fi en mode STA.");
    Serial.print("Adresse IP en mode STA: ");
    Serial.println(WiFi.localIP());
    Serial.println("Point d'Accès Wi-Fi démarré avec succès!");
    Serial.print("Adresse IP du Point d'Accès: ");
    Serial.println(WiFi.softAPIP());
}

bool WifiController::isConnected() {
    return WiFi.status() == WL_CONNECTED;
}

IPAddress WifiController::getLocalIP() {
    return WiFi.localIP();
}
