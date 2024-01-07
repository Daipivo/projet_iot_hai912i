#ifndef WiFiManager_h
#define WiFiManager_h

#include <Arduino.h>
#include <WiFi.h>

class WifiManager {
public:
    WifiManager(const char* sta_ssid, const char* sta_password);
    void connect();
    bool isConnected();
    IPAddress getLocalIP();

private:
    const char* _sta_ssid;
    const char* _sta_password;
};

#endif
