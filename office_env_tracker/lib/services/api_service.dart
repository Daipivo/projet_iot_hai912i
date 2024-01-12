import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

import '../model/sensor.dart';
import 'dart:async';

import 'package:office_env_tracker/utils/app_theme.dart';

class APIService {
  static final APIService _instance = APIService._internal();

  APIService._internal();

  static APIService get instance => _instance;

  String _urlBase = '127.0.0.1/api';

  void setUrlBase(String ipAddress) {
    _urlBase = "http://$ipAddress/api";
  }

  String getUrlBase() {
    return _urlBase;
  }

  Future<String> fetchLedStatus(String sensorType) async {
    String url = "$_urlBase/${sensorType}Led/status";
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        log('Réponse HTTP non réussie: ${response.statusCode}');
        throw Exception('Failed to load LED status');
      }
    } catch (e) {
      log('Erreur lors de la récupération du statut de la LED: $e');
      throw Exception('Failed to load LED status');
    }
  }

  Future<void> toggleLed(
      bool newValue, String sensorType, Function(bool) onStateChanged) async {
    String sensorUrl = sensorType == AppStrings.temperature
        ? AppStrings.temperatureUrl
        : AppStrings.luminosityUrl;

    String url = "$_urlBase/${sensorUrl}Led";
    String newState = newValue ? 'on' : 'off';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'state': newState}),
      );
      if (response.statusCode == 200) {
        log('LED toggled successfully.');
        onStateChanged(
            newValue); // Exécute la fonction de rappel avec le nouvel état
      } else {
        log('Échec de la commutation de la LED: ${response.statusCode}');
        throw Exception('Failed to toggle LED');
      }
    } catch (e) {
      log('Erreur lors de la commutation de la LED: $e');
      throw Exception('Failed to toggle LED');
    }
  }

  Future<Map<String, dynamic>> fetchData(String type) async {
    String url = "$_urlBase/$type/status";

    log(url);

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        log(responseBody
            .toString()); // Convertit l'objet Dart en String pour le log
        return responseBody;
      } else {
        log('Réponse HTTP non réussie: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      log('Erreur lors de la récupération des données: $e');
      throw Exception('Failed to load data');
    }
  }

  Future<bool> manageControl(Sensor sensor, bool newState) async {
    String sensorUrl = sensor.type == AppStrings.temperature
        ? AppStrings.temperatureUrl
        : AppStrings.luminosityUrl;

    String controlUrl = "$_urlBase/$sensorUrl/control";
    try {
      final response = await http.patch(
        Uri.parse(controlUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'state': newState ? 'on' : 'off'}),
      );
      if (response.statusCode == 200) {
        // Mettre à jour le statut automatique du capteur si nécessaire
        sensor.automatique = newState;
        return true;
      } else {
        log("Échec de la requête de contrôle: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      log("Erreur lors de l'exécution de manageControl: $e");
      return false;
    }
  }

  Future<bool> updateSensorThreshold(Sensor sensor, double newThreshold) async {
    String sensorType =
        sensor.type == AppStrings.temperature ? "temperature" : "luminosity";

    String url = "$_urlBase/$sensorType/threshold";
    log(url);

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'value': newThreshold.toString()}),
      );

      if (response.statusCode == 200) {
        sensor.seuil = newThreshold;
        return true;
      } else {
        log("Erreur: Code de statut ${response.statusCode}");
        return false;
      }
    } catch (e) {
      log("Exception lors de la mise à jour du seuil: $e");
      return false;
    }
  }
}
