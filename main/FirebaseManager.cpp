#include "FirebaseManager.h"
#include "Config.h"

// Generates a unique UUID
String generateUUID() {
    uint64_t chipid = ESP.getEfuseMac(); // Obtient l'ID du chip ESP32
    char chipid_str[23];
    snprintf(chipid_str, sizeof(chipid_str), "%04X%08X", (uint16_t)(chipid>>32), (uint32_t)chipid);

    time_t now;
    time(&now);
    char time_str[20];
    strftime(time_str, sizeof(time_str), "%Y%m%d%H%M%S", localtime(&now));

    String uuid = String(chipid_str) + String(time_str);
    return uuid;
}

// Private constructor for the singleton pattern
FirebaseManager::FirebaseManager() : lastSendTime(0) {
    config.api_key = API_KEY; 
    auth.user.email = USER_EMAIL;
    auth.user.password = USER_PASSWORD;
    project_id = FIREBASE_PROJECT_ID; 
}

// Method to access the singleton instance
FirebaseManager& FirebaseManager::getInstance() {
    static FirebaseManager instance;
    return instance;
}

// Init firebase with settings
void FirebaseManager::begin() {
    Firebase.begin(&config, &auth);
    while (auth.token.uid == "") {
        delay(1000);
    }
    uid = auth.token.uid.c_str();
}


// Send temperature sensor data to Firebase
bool FirebaseManager::sendSensorData(float value, String sensor) {
    time_t now;
    time(&now);
    char dateTimeStr[20];
    strftime(dateTimeStr, sizeof(dateTimeStr), "%Y-%m-%d %H:%M:%S", localtime(&now));

    FirebaseJson content;
    content.set("fields/type/stringValue", sensor);
    content.set("fields/roomId/stringValue", ROOM_LOCATION_ID);
    content.set("fields/value/doubleValue", value);
    content.set("fields/dateTime/stringValue", String(dateTimeStr));

    String documentUID = generateUUID();
    String documentPath = "measures/" + documentUID;

    return Firebase.Firestore.createDocument(&fbdo, project_id.c_str(), "", documentPath.c_str(), content.raw());
}

// Update the IP address for a given room
bool FirebaseManager::updateIpAddress(String roomId, String ipAddress) {
  
  String documentPath = "rooms/" + roomId;

  FirebaseJson content;
  content.set("fields/ipAddress/stringValue", ipAddress);

  if (Firebase.Firestore.patchDocument(&fbdo, project_id.c_str(), "", documentPath.c_str(), content.raw(), "ipAddress")) {
      return true;
  } else {
      Serial.println("Échec de la mise à jour de l'adresse IP: " + fbdo.errorReason());
      return false;
  }
}

