  #include "FirebaseManager.h"
  #include "Config.h"

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
  // Constructeur privé pour le singleton
  FirebaseManager::FirebaseManager() : lastSendTime(0) {
      config.api_key = API_KEY; 
      auth.user.email = USER_EMAIL;
      auth.user.password = USER_PASSWORD;
      project_id = FIREBASE_PROJECT_ID; 
  }

  // Méthode d'accès à l'instance singleton
  FirebaseManager& FirebaseManager::getInstance() {
      static FirebaseManager instance;
      return instance;
  }

  // Méthode pour initialiser Firebase
  void FirebaseManager::begin() {
      Firebase.begin(&config, &auth);
      while (auth.token.uid == "") {
          delay(1000); // Attendre l'UID
      }
      uid = auth.token.uid.c_str();
  }


  // Méthode pour envoyer les données de température
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

  bool FirebaseManager::updateIpAddress(String roomId, String ipAddress) {
    // Créer un chemin de document
    String documentPath = "rooms/" + roomId;

    // Créer le contenu JSON pour la mise à jour
    FirebaseJson content;
    content.set("fields/ipAddress/stringValue", ipAddress); // Mettre à jour l'adresse IP

    // Effectuer la mise à jour
    if (Firebase.Firestore.patchDocument(&fbdo, project_id.c_str(), "", documentPath.c_str(), content.raw(), "ipAddress")) {
        return true;
    } else {
        Serial.println("Échec de la mise à jour de l'adresse IP: " + fbdo.errorReason());
        return false;
    }
}

