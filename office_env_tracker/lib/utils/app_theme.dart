import 'package:flutter/material.dart';

class AppColors {
  static const primaryColor = Color(0xFFDFD5EC);
  static const buttonSelectedColor = Color(0xFF9F88DC);
  static const buttonUnselectedColor = Color(0xFFF3EDF7);
  static const cardColor = Color(0xFFF3EDF7);
  static const cardData = Color(0xFF21005D);
}

class AppStrings {
  static const titleVisualizationPage =
      'Visualiser l’éclairage et la température';
  static const titleSettingsPage = 'Gérer les paramètres de vos capteurs';
  static const titleStatisticsPage = 'Visualiser les statistiques';
  static const lightOnStatus = 'La lumière est activée';
  static const lightOffStatus = 'La lumière est éteinte';
  static const stateLight = 'Etat de la lumière :';
  static const luminosity = 'Luminosité';
  static const temperature = 'Température';
  static const luminosityTitleCard = 'Luminosité :';
  static const temperatureTitleCard = 'Température :';
  static const loadingData = 'Chargement...';
  static const seuil = 'Seuil';
  static const activateLedSeuilTitle = "Activation de la lumière";
  static const activateLedSeuilSubTitle = "En fonction du seuil";
  static const modifySeuil = "Modification du seuil";
  static const selectedValueSeuil = "Valeur sélectionnée :";
  static const informationThresholdTemperature =
      "Si la température actuelle est supérieure au seuil, alors on allume la lumière.";
  static const informationThresholdLuminosity =
      "Si la luminosité actuelle est inférieure au seuil, alors on allume la lumière.";
}
