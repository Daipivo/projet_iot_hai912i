import '../model/sensor.dart';
import '../utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class SensorDataService extends ChangeNotifier {
  static final SensorDataService _instance = SensorDataService._internal();

  factory SensorDataService() {
    return _instance;
  }

  SensorDataService._internal();

  Sensor temperatureSensor = Sensor(
    type: AppStrings.temperature,
    icon: Icons.thermostat,
    valeur: 0.00,
    seuil: 0.00,
    unit: '°C',
    automatique: false,
  );

  Sensor luminositySensor = Sensor(
    type: AppStrings.luminosity,
    icon: Icons.lightbulb_outline,
    valeur: 0.00,
    seuil: 0.00,
    unit: ' V',
    automatique: false,
  );

  bool isLightOn = false;

  void updateTemperatureSensor(double valeur, double seuil, bool automatique) {
    temperatureSensor.valeur = valeur;
    temperatureSensor.seuil = seuil;
    temperatureSensor.automatique = automatique;
    notifyListeners();
  }

  void updateLuminositySensor(double valeur, double seuil, bool automatique) {
    luminositySensor.valeur = valeur;
    luminositySensor.seuil = seuil;
    luminositySensor.automatique = automatique;
    notifyListeners();
  }

  void updateLed(bool isOn) {
    isLightOn = isOn;
    notifyListeners();
  }
}
