#ifndef FirebaseManager_h
#define FirebaseManager_h

#include <Firebase_ESP_Client.h>
#include <time.h>
#include <WiFi.h>

class FirebaseManager {
public:
    static FirebaseManager& getInstance();
    void begin();
    bool sendSensorData(float value, String sensor);
    bool updateIpAddress(String roomId, String ipAddress);
    // Interdisez la copie
    FirebaseManager(FirebaseManager const&) = delete;
    void operator=(FirebaseManager const&) = delete;

private:
    FirebaseManager();
    FirebaseData fbdo;
    FirebaseAuth auth;
    FirebaseConfig config;
    String uid;
    String project_id;
    unsigned long lastSendTime;
    const unsigned long sendDataInterval = 180000;
};

#endif
