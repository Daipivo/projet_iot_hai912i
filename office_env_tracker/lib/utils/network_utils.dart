import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

import '../model/sensor.dart';
import 'dart:async';

import 'package:office_env_tracker/utils/app_theme.dart';

String urlBase = '127.0.0.1/api';

void setUrlBase(String ipAddress) {
  urlBase = "http://$ipAddress/api";
}

Future<String> fetchLedStatus(String sensorType) async {
  String url = "$urlBase/${sensorType}Led/status";
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
    bool isOn, String sensorType, Function(bool) onStateChanged) async {
  String sensorUrl = sensorType == AppStrings.temperature
      ? AppStrings.temperatureUrl
      : AppStrings.luminosityUrl;

  String url =
      isOn ? "$urlBase/${sensorUrl}Led/on" : "$urlBase/${sensorUrl}Led/off";
  log(url);

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      onStateChanged(isOn);
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
  String url = "$urlBase/$type/status";

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

Future<bool> manageControl(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    return response.statusCode == 200;
  } catch (e) {
    log("Erreur lors de l'exécution de manageControl: $e");
    return false;
  }
}

Future<bool> updateSensorThreshold(Sensor sensor, double newThreshold) async {
  String sensorType =
      sensor.type == AppStrings.temperature ? "temperature" : "luminosity";

  String url = "$urlBase/$sensorType/threshold";
  log(url);

  try {
    final response = await http.put(
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
