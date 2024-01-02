  #include "FirebaseController.h"
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
  FirebaseController::FirebaseController() : lastSendTime(0) {
      config.api_key = API_KEY; 
      auth.user.email = USER_EMAIL;
      auth.user.password = USER_PASSWORD;
      project_id = FIREBASE_PROJECT_ID; 
  }

  // Méthode d'accès à l'instance singleton
  FirebaseController& FirebaseController::getInstance() {
      static FirebaseController instance;
      return instance;
  }

  // Méthode pour initialiser Firebase
  void FirebaseController::begin() {
      Firebase.begin(&config, &auth);
      while (auth.token.uid == "") {
          delay(1000); // Attendre l'UID
      }
      uid = auth.token.uid.c_str();
  }


  // Méthode pour envoyer les données de température
  bool FirebaseController::sendSensorData(float value, bool controlState, float threshold, String sensor) {
      time_t now;
      time(&now);
      char dateTimeStr[20];
      strftime(dateTimeStr, sizeof(dateTimeStr), "%Y-%m-%d %H:%M:%S", localtime(&now));

      FirebaseJson content;
      content.set("fields/value/doubleValue", value);
      content.set("fields/controlEnabled/booleanValue", controlState);
      content.set("fields/threshold/doubleValue", threshold);
      content.set("fields/dateTime/stringValue", String(dateTimeStr)); // Ajout de la date et de l'heure

      String documentUID = generateUUID();
      String documentPath = sensor + "/" + ROOM_LOCATION_ID + "/" + documentUID;

      return Firebase.Firestore.createDocument(&fbdo, project_id.c_str(), "", documentPath.c_str(), content.raw());
  }

  bool FirebaseController::updateIpAddress(String roomId, String ipAddress) {
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

