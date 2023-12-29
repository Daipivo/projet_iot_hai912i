import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/commons.dart';
import '../model/sensor.dart';
import '../utils/network_utils.dart';
import '../services/sensor_data.dart';
import 'dart:developer';

class VisualizationPage extends StatefulWidget {
  @override
  VisualizationPageState createState() => VisualizationPageState();
}

class VisualizationPageState extends State<VisualizationPage>
    with WidgetsBindingObserver {
  String selectedRoom = 'Bureau 1';

  bool isLightOn = false;

  bool isAutomatic = false;

  String temperature = '';
  String luminosity = '';

  late Sensor temperatureSensor;
  late Sensor luminositySensor;

  final EdgeInsets elementPadding = const EdgeInsets.all(8.0);

  @override
  void initState() {
    super.initState();
    var sensorService = SensorDataService();
    sensorService.addListener(_updateSensorData);
    loadData();
  }

  void _updateSensorData() {
    var sensorService = SensorDataService();
    setState(() {
      temperatureSensor = sensorService.temperatureSensor;
      luminositySensor = sensorService.luminositySensor;
      temperature = "${temperatureSensor.valeur.toStringAsFixed(1)}°C";
      luminosity = "${luminositySensor.valeur.toStringAsFixed(1)} V";
      isAutomatic =
          temperatureSensor.automatique || luminositySensor.automatique;

      bool isTemperatureHigh =
          temperatureSensor.valeur > temperatureSensor.seuil;
      bool isLuminosityLow = luminositySensor.valeur < luminositySensor.seuil;
      isLightOn = isTemperatureHigh || isLuminosityLow;
    });
  }

  @override
  void dispose() {
    SensorDataService().removeListener(_updateSensorData);
    super.dispose();
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
      temperature = AppStrings.loadingData;
      luminosity = AppStrings.loadingData;
    });

    try {
      var sensorService = SensorDataService();

      String ledStatus = await fetchLedStatus();
      isLightOn = ledStatus == "LED allumée";

      Map<String, dynamic> dataTemperature = await fetchData("temperature");

      double tempValeur =
          double.parse(dataTemperature['temperature'].toString());
      double tempSeuil = double.parse(dataTemperature['threshold'].toString());
      bool tempAutomatique = dataTemperature['controlEnabled'] == true;

      sensorService.updateTemperatureSensor(
          tempValeur, tempSeuil, tempAutomatique);

      Map<String, dynamic> dataLuminosity = await fetchData("luminosity");

      double lumiValeur = double.parse(dataLuminosity['luminosity'].toString());
      double lumiSeuil = double.parse(dataLuminosity['threshold'].toString());
      bool lumiAutomatique = dataLuminosity['controlEnabled'] == true;

      sensorService.updateLuminositySensor(
          lumiValeur, lumiSeuil, lumiAutomatique);

      // Utiliser les données mises à jour depuis le service singleton
      setState(() {
        temperatureSensor = sensorService.temperatureSensor;
        luminositySensor = sensorService.luminositySensor;

        temperature = "${temperatureSensor.valeur.toStringAsFixed(1)}°C";
        luminosity = "${luminositySensor.valeur.toStringAsFixed(1)} V";
      });
    } catch (e) {
      setState(() {
        temperature = "Non disponible";
        luminosity = "Non disponible";
        isLightOn = false;
      });
    }
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
            style: TextStyle(fontSize: 18), AppStrings.titleVisualizationPage),
        actions: [
          // Ajoutez des actions si nécessaire
        ],
      ),
      backgroundColor: AppColors.primaryColor,
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 12.0),
            _buildHorizontalButtonRow(),
            const SizedBox(height: 32.0),
            _buildCard(context, AppStrings.temperatureTitleCard, temperature,
                Icons.thermostat_outlined),
            const SizedBox(height: 18.0),
            _buildCard(context, AppStrings.luminosityTitleCard, luminosity,
                Icons.wb_sunny_outlined),
            const SizedBox(height: 18.0),
            _buildLightStatus(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalButtonRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Commons.buildButton(context, 'Bureau 1', Icons.computer,
              () => _onRoomSelected('Bureau 1'), selectedRoom),
          const SizedBox(width: 10.0),
          Commons.buildButton(context, 'Bureau 2', Icons.computer,
              () => _onRoomSelected('Bureau 2'), selectedRoom),
          const SizedBox(width: 10.0),
          Commons.buildButton(context, 'Bureau 3', Icons.computer,
              () => _onRoomSelected('Bureau 3'), selectedRoom),
          const SizedBox(width: 10.0),
          Commons.buildButton(context, 'Bureau 4', Icons.computer,
              () => _onRoomSelected('Bureau 4'), selectedRoom),
        ],
      ),
    );
  }

  void _onRoomSelected(String roomName) {
    loadData();
    setState(() {
      selectedRoom = roomName;
    });
  }

  Widget _buildCard(
      BuildContext context, String title, String data, IconData icon) {
    return Card(
      color: AppColors.cardColor,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding externe de la Card
        child: Column(
          mainAxisSize: MainAxisSize.min, // S'adapte au contenu
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Utilisation de Row pour aligner le titre et l'icône
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  // Expanded pour occuper tout l'espace horizontal disponible
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(icon, size: 32), // Icône alignée à droite
              ],
            ),
            SizedBox(
                height:
                    8), // Espace entre le titre / icône et le contenu suivant
            // Contenu du texte
            Text(
              data.isNotEmpty ? data : AppStrings.loadingData,
              style: const TextStyle(
                color: AppColors.cardData,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLightStatus(BuildContext context) {
    String lightStatusText = isLightOn
        ? AppStrings.lightOnStatus
        : AppStrings.lightOffStatus; // Utiliser une condition ici

    String autoModeText =
        "Mode Automatique: " + (isAutomatic ? "Activé" : "Désactivé");

    return Card(
      color: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                AppStrings.stateLight,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              autoModeText,
              style: const TextStyle(
                fontSize: 14.0, // Vous pouvez ajuster la taille de police ici
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    lightStatusText,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Switch(
                  value: isLightOn,
                  onChanged: isAutomatic
                      ? null
                      : (bool newValue) {
                          toggleLed(newValue, (bool newState) {
                            setState(() {
                              isLightOn = newState;
                            });
                          });
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
