#include "WifiManager.h"


WifiManager::WifiManager(const char* sta_ssid, const char* sta_password) 
: _sta_ssid(sta_ssid), _sta_password(sta_password) {}

void WifiManager::connect() {
    Serial.println("\nDémarrage du Point d'Accès Wi-Fi...");

    WiFi.mode(WIFI_STA); // Mode AP+STA
    WiFi.begin(_sta_ssid, _sta_password); // Se connecter au réseau Wi-Fi

    // Attendre la connexion au réseau Wi-Fi
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }

    Serial.println("\nConnecté au réseau Wi-Fi en mode STA.");
    Serial.print("Adresse IP en mode STA: ");
    String localIp = WiFi.localIP().toString();
    Serial.println(localIp);
}

bool WifiManager::isConnected() {
    return WiFi.status() == WL_CONNECTED;
}

IPAddress WifiManager::getLocalIP() {
    return WiFi.localIP();
}
