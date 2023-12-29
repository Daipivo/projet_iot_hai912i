import 'package:flutter/material.dart';

class Sensor {
  String type;
  IconData icon;
  double valeur;
  double seuil;
  String unit;
  bool automatique;

  Sensor({
    required this.type,
    required this.icon,
    required this.valeur,
    required this.seuil,
    required this.unit,
    this.automatique = false,
  });
}
