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
      isLedOn: false);

  Sensor luminositySensor = Sensor(
      type: AppStrings.luminosity,
      icon: Icons.lightbulb_outline,
      valeur: 0.00,
      seuil: 0.00,
      unit: ' V',
      automatique: false,
      isLedOn: false);

  void updateTemperatureLed(bool isOn) {
    temperatureSensor.isLedOn = isOn;
    notifyListeners();
  }

  void updateLuminosityLed(bool isOn) {
    luminositySensor.isLedOn = isOn;
    notifyListeners();
  }

  void updateTemperatureSensor(double valeur, double seuil, bool automatique) {
    temperatureSensor.valeur = valeur;
    temperatureSensor.seuil = seuil;
    temperatureSensor.automatique = automatique;
    temperatureSensor.isLedOn = (automatique && valeur < seuil) ||
        (!automatique && temperatureSensor.isLedOn);
    notifyListeners();
  }

  void updateLuminositySensor(double valeur, double seuil, bool automatique) {
    luminositySensor.valeur = valeur;
    luminositySensor.seuil = seuil;
    luminositySensor.automatique = automatique;
    luminositySensor.isLedOn = (automatique && valeur < seuil) ||
        (!automatique && luminositySensor.isLedOn);
    notifyListeners();
  }
}
