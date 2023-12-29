import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

import 'dart:async';

String urlBase = "http://192.168.4.1";

Future<String> fetchLedStatus() async {
  String url = "$urlBase/led/status";
  log(url);
  try {
    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 1));
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

Future<void> toggleLed(bool isOn, Function(bool) onStateChanged) async {
  String url = isOn ? "$urlBase/led/on" : "$urlBase/led/off";
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
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 1));
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

Future<http.Response> manageControl(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    // Vous pouvez effectuer des vérifications supplémentaires ici si nécessaire
    return response;
  } catch (e) {
    // Gérer les exceptions ici
    // Vous pouvez renvoyer une réponse personnalisée ou lever à nouveau l'exception
    throw e;
  }
}
