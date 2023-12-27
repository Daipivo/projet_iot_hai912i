import 'dart:developer';

import 'package:flutter/material.dart';
import '../utils/network_utils.dart';
import '../utils/app_theme.dart';
import '../utils/commons.dart';
import '../model/sensor.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with WidgetsBindingObserver {
  String valueText = "";
  String seuilText = "";

  late Sensor temperatureSensor;
  late Sensor luminositySensor;
  late Sensor selectedSensor;

  _SettingsPageState() {
    temperatureSensor = Sensor(
      type: AppStrings.temperature,
      icon: Icons.thermostat,
      valeur: 0.00,
      seuil: 20,
      automatique: false,
    );

    luminositySensor = Sensor(
      type: AppStrings.luminosity,
      icon: Icons.lightbulb_outline,
      valeur: 0.00,
      seuil: 2.0,
      automatique: false,
    );

    selectedSensor = temperatureSensor;
  }

  final EdgeInsets elementPadding = const EdgeInsets.all(16.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state); // Ajouter cet appel
    if (state == AppLifecycleState.resumed) {
      loadData();
    }
  }

  Future<void> loadData() async {
    setState(() {
      valueText = AppStrings.loadingData;
      seuilText = AppStrings.loadingData;
    });

    try {
      if (selectedSensor.type == AppStrings.temperature) {
        valueText = await Commons.fetchTemperature();
        seuilText = await Commons.fetchTemperature();
      } else if (selectedSensor.type == AppStrings.luminosity) {
        valueText = await Commons.fetchLuminosity();
        seuilText = await Commons.fetchLuminosity();
      }
    } catch (e) {}

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          AppStrings.titleSettingsPage,
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          // Ajoutez des actions si nécessaire
        ],
      ),
      backgroundColor: AppColors.primaryColor,
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(children: <Widget>[
          const SizedBox(height: 12.0),
          _buildHorizontalButtonRow(),
          const SizedBox(height: 32.0),
          _buildCard(context, selectedSensor),
          const SizedBox(height: 18.0),
          _buildSlider(selectedSensor)
        ]),
      ),
    );
  }

  Widget _buildHorizontalButtonRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Commons.buildButton(
              context,
              AppStrings.temperature,
              Icons.thermostat,
              () => setState(
                  () => {loadData(), selectedSensor = temperatureSensor}),
              selectedSensor.type,
              width: MediaQuery.of(context).size.width /
                  2.25, // Largeur définie à un tiers de la largeur de l'écran
            ),
            const SizedBox(width: 20.0),
            Commons.buildButton(
              context,
              AppStrings.luminosity,
              Icons.lightbulb_outline,
              () => setState(
                  () => {loadData(), selectedSensor = luminositySensor}),
              selectedSensor.type,
              width: MediaQuery.of(context).size.width /
                  2.25, // Largeur définie à un tiers de la largeur de l'écran
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Sensor sensor) {
    String sensorValueDisplay = (valueText == "Non disponible" ||
            valueText == "Chargement...")
        ? valueText
        : "${valueText}${sensor.type == AppStrings.temperature ? '°C' : ' V'}";

    // Seuil du capteur
    String seuilDisplay = (seuilText == "Non disponible" ||
            seuilText == "Chargement...")
        ? seuilText
        : "${seuilText}${sensor.type == AppStrings.temperature ? '°C' : ' V'}";

    return Card(
      color: AppColors.cardColor,
      margin: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(16.0), // Appliquer le padding ici
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Titre du capteur (Type)
                Expanded(
                  child: Text(
                    sensor.type,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                // Icône du capteur
                Icon(sensor.icon, size: 32),
              ],
            ),
            const SizedBox(height: 8),
            // Valeur du capteur
            Text(
              sensorValueDisplay,
              style: const TextStyle(
                color: AppColors.cardData,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 10),
            // Row pour text1 et text2
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.seuil,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 8), // Espace entre Text1 et Text2
                Text(
                  seuilDisplay,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.zero, // Supprime tout padding interne
              child: ListTile(
                title: const Text(AppStrings.activateLedSeuilTitle,
                    style: TextStyle(/* vos styles de texte ici */)),
                subtitle: const Text(AppStrings.activateLedSeuilSubTitle,
                    style: TextStyle(/* vos styles de texte secondaire ici */)),
                trailing: Transform.scale(
                  scale: 0.9, // Ajustez la taille du Switch si nécessaire
                  child: Switch(
                    value: sensor.automatique,
                    onChanged: (bool newValue) {
                      setState(() {
                        sensor.automatique = newValue;
                      });
                    },
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(Sensor sensor) {
    // Vérifier si le capteur est un capteur de luminosité et ajuster les paramètres en conséquence
    bool isLuminositySensor = sensor.type == AppStrings.luminosity;
    double min = isLuminositySensor ? 0.0 : -10.0;
    double max = isLuminositySensor ? 3.5 : 30.0;
    int divisions = isLuminositySensor ? 35 : 40;

    // S'assurer que la valeur du seuil est dans la plage valide pour le type de capteur
    double sliderValue = sensor.seuil.toDouble();
    // Si le seuil est en dehors de la plage valide, le définir sur la valeur minimale
    sliderValue =
        (sliderValue >= min && sliderValue <= max) ? sliderValue : min;

    // Construire le label pour le Slider
    String valueLabel = isLuminositySensor
        ? "${sliderValue.toStringAsFixed(2)}V"
        : "${sliderValue.round()}°C";

    return Card(
      color: AppColors.cardColor,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              AppStrings.modifySeuil,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(min.toString()),
                Expanded(
                  child: Slider(
                    value: sliderValue,
                    min: min,
                    max: max,
                    divisions: divisions,
                    label: valueLabel,
                    onChanged: (double value) {
                      setState(() {
                        sensor.seuil = (value * 10).round() / 10;
                      });
                    },
                  ),
                ),
                Text(max.toString()),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(AppStrings.selectedValueSeuil),
                  Text(valueLabel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
