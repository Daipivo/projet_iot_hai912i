#ifndef FirebaseController_h
#define FirebaseController_h

#include <Firebase_ESP_Client.h>
#include <time.h>
#include <WiFi.h>

class FirebaseController {
public:
    static FirebaseController& getInstance();
    void begin();
    bool sendSensorData(float value, bool controlState, float threshold, String sensor);

    // Interdisez la copie
    FirebaseController(FirebaseController const&) = delete;
    void operator=(FirebaseController const&) = delete;

private:
    FirebaseController();
    FirebaseData fbdo;
    FirebaseAuth auth;
    FirebaseConfig config;
    String uid;
    String project_id;
    unsigned long lastSendTime;
    const unsigned long sendDataInterval = 180000;
};

#endif
