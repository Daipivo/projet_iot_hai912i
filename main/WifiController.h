#ifndef WiFiController_h
#define WiFiController_h

#include <Arduino.h>
#include <WiFi.h>

class WifiController {
public:
    WifiController(const char* ap_ssid, const char* ap_password, const char* sta_ssid, const char* sta_password);
    void connect();
    bool isConnected();
    IPAddress getLocalIP();

private:
    const char* _ap_ssid;
    const char* _ap_password;
    const char* _sta_ssid;
    const char* _sta_password;
};

#endif
