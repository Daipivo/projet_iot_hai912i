import 'dart:developer';

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../utils/commons.dart';
import '../model/sensor.dart';
import '../data/sensor_data.dart';
import 'dart:developer';

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
  late SensorData sensorData;
  late APIService apiService;

  final EdgeInsets elementPadding = const EdgeInsets.all(16.0);

  @override
  void initState() {
    super.initState();
    sensorData = SensorData();
    apiService = APIService();
    sensorData.addListener(_updateSensorData);
    temperatureSensor = sensorData.temperatureSensor;
    luminositySensor = sensorData.luminositySensor;
    selectedSensor = temperatureSensor;
    _updateSensorSelection();
  }

  void _updateSensorData() {
    setState(() {
      _updateSensorSelection();
    });
  }

  void _updateSensorSelection() {
    selectedSensor = selectedSensor.type == AppStrings.luminosity
        ? luminositySensor
        : temperatureSensor;
    _updateDisplayValues();
  }

  void _updateDisplayValues() {
    valueText = selectedSensor.valeur.toStringAsFixed(1);
    seuilText = selectedSensor.seuil.toStringAsFixed(1);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      loadData();
    }
  }

  @override
  void dispose() {
    sensorData.removeListener(_updateSensorData);
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => _setLoadingState());

    try {
      await _fetchSensorData();
      _updateSensorSelection();
      setState(() {});
    } catch (e) {
      setState(() => _setErrorState());
    }
  }

  Future<void> _fetchSensorData() async {
    if (selectedSensor.type == AppStrings.temperature) {
      Map<String, dynamic> data = await apiService.fetchData("temperature");
      double tempValeur = double.parse(data['temperature'].toString());
      double tempSeuil = double.parse(data['threshold'].toString());
      bool tempAutomatique = data['controlEnabled'] == true;

      sensorData.updateTemperatureSensor(
          tempValeur, tempSeuil, tempAutomatique);
    } else if (selectedSensor.type == AppStrings.luminosity) {
      Map<String, dynamic> data = await apiService.fetchData("luminosity");
      double lumiValeur = double.parse(data['luminosity'].toString());
      double lumiSeuil = double.parse(data['threshold'].toString());
      bool lumiAutomatique = data['controlEnabled'] == true;

      sensorData.updateLuminositySensor(lumiValeur, lumiSeuil, lumiAutomatique);
    }
  }

  void _setLoadingState() {
    valueText = AppStrings.loadingData;
    seuilText = AppStrings.loadingData;
  }

  void _setErrorState() {
    valueText = "Non disponible";
    seuilText = "Non disponible";
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
              () => _onSensorSelected(temperatureSensor),
              selectedSensor.type,
              width: MediaQuery.of(context).size.width / 2.25,
            ),
            const SizedBox(width: 20.0),
            Commons.buildButton(
              context,
              AppStrings.luminosity,
              Icons.lightbulb_outline,
              () => _onSensorSelected(luminositySensor),
              selectedSensor.type,
              width: MediaQuery.of(context).size.width / 2.25,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      AppStrings.seuil,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(
                        width: 8), // Espace entre le texte "Seuil" et l'icône
                    GestureDetector(
                      onTap: () =>
                          _showThresholdInfo(context, selectedSensor.type),
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ],
                ),
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
                    onChanged: (bool newValue) async {
                      bool success =
                          await apiService.manageControl(sensor, newValue);
                      if (success) {
                        // Mise à jour de l'état global
                        if (sensor.type == AppStrings.temperature) {
                          sensorData.updateTemperatureSensor(
                              sensor.valeur, sensor.seuil, newValue);
                        } else if (sensor.type == AppStrings.luminosity) {
                          sensorData.updateLuminositySensor(
                              sensor.valeur, sensor.seuil, newValue);
                        }
                        // Mise à jour de l'état local
                        _updateSensorData();
                      } else {
                        log("Échec de la mise à jour de l'état du capteur.");
                      }
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
                      onChangeEnd: (double value) async {
                        bool success = await apiService.updateSensorThreshold(
                            sensor, sensor.seuil);
                        if (success) {
                          if (mounted) {
                            setState(() {
                              _updateDisplayValues();
                              if (sensor.type == AppStrings.temperature) {
                                sensorData.updateTemperatureSensor(
                                  sensor.valeur,
                                  sensor.seuil,
                                  sensor.automatique,
                                );
                              } else if (sensor.type == AppStrings.luminosity) {
                                sensorData.updateLuminositySensor(
                                  sensor.valeur,
                                  sensor.seuil,
                                  sensor.automatique,
                                );
                              }
                            });
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Échec de la mise à jour du seuil")),
                            );
                          }
                        }
                      }),
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

  void _onSensorSelected(Sensor sensor) {
    setState(() {
      selectedSensor = sensor;
      _updateDisplayValues();
    });
    loadData();
  }

  void _showThresholdInfo(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Information sur le seuil"),
          content: Text(
            type == AppStrings.temperature
                ? AppStrings.informationThresholdTemperature
                : AppStrings.informationThresholdLuminosity,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Fermer"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
