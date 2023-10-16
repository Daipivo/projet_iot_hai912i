#ifndef WIFI_CONTROLLER_H
#define WIFI_CONTROLLER_H

#include <WiFi.h>

class WiFiController {

public:    
    WiFiController(const char* ssid, const char* password);

    void connect();
    bool isConnected();
    IPAddress getLocalIP();

private:
    const char* _ssid;
    const char* _password;

};

#endif
