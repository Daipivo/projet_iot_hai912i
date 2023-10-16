#include "WiFiController.h"

WiFiController::WiFiController(const char* ssid, const char* password) : _ssid(ssid), _password(password) {
    initializeSerial();
}

void WiFiController::initializeSerial() {
    Serial.begin(115200);  // Initialiser le port série pour le débogage
    delay(10);
}

void WiFiController::connect() {
    Serial.println("\nConnexion au Wi-Fi...");

    WiFi.begin(_ssid, _password);

    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }

    Serial.println("");
    Serial.println("Connecté au Wi-Fi avec succès!");
    Serial.print("Adresse IP: ");
    Serial.println(WiFi.localIP());
}

bool WiFiController::isConnected() {
    return WiFi.status() == WL_CONNECTED;
}

IPAddress WiFiController::getLocalIP() {
    return WiFi.localIP();
}
