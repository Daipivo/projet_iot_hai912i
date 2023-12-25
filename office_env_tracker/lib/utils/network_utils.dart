import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

import 'dart:async';

Future<String> fetchData(String url, String key) async {
  try {
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 1)); // Augmentation du délai d'expiration
    if (response.statusCode == 200) {
      return json.decode(response.body)[key];
    } else {
      log('Réponse HTTP non réussie: ${response.statusCode}');
      return "Non disponible";
    }
  } catch (e) {
    log('Erreur lors de la récupération des données: $e');
    return "Non disponible";
  }
}
