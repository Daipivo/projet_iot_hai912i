import 'package:flutter/material.dart';

class Sensor {
  String type;
  IconData icon;
  double valeur;
  double seuil;
  bool automatique;

  Sensor({
    required this.type,
    required this.icon,
    required this.valeur,
    required this.seuil,
    this.automatique = false,
  });
}
