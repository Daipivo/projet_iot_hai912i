import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/commons.dart';
import '../model/sensor.dart';
import '../utils/network_utils.dart';
import '../services/sensor_data.dart';
import '../services/firestore.dart';
import 'dart:developer';

class VisualizationPage extends StatefulWidget {
  @override
  VisualizationPageState createState() => VisualizationPageState();
}

class VisualizationPageState extends State<VisualizationPage>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> rooms = [];

  late FirestoreService firestoreService;
  String selectedRoom = 'Bureau 1';
  bool isAutomatic = false;
  String temperature = '';
  String luminosity = '';
  late Sensor temperatureSensor;
  late Sensor luminositySensor;
  bool isTemperatureLedOn = false;
  bool isLuminosityLedOn = false;

  final EdgeInsets elementPadding = const EdgeInsets.all(8.0);
  late final SensorDataService
      sensorService; // Utilisation d'une instance unique

  @override
  void initState() {
    super.initState();
    firestoreService = FirestoreService.instance;
    // _loadRooms();
    sensorService = SensorDataService(); // Initialisation de l'instance unique
    temperatureSensor = sensorService.temperatureSensor;
    luminositySensor = sensorService.luminositySensor;
    sensorService.addListener(_updateSensorData);
    loadData();
  }

  Future<void> _loadRooms() async {
    rooms = await firestoreService.getRooms();
    if (mounted) setState(() {});
  }

  void _updateSensorData() {
    setState(() {
      _setSensorData();
    });
  }

  void _setSensorData() {
    // log(rooms.length.toString());
    temperature = "${temperatureSensor.valeur.toStringAsFixed(1)}°C";
    luminosity = "${luminositySensor.valeur.toStringAsFixed(1)} V";
  }

  Future<void> loadData() async {
    setState(() => _setLoadingState());
    // _loadRooms();
    try {
      await _fetchAndUpdateSensorData();
      _setSensorData();
    } catch (e) {
      _setErrorState();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _setLoadingState() {
    temperature = AppStrings.loadingData;
    luminosity = AppStrings.loadingData;
  }

  void _setErrorState() {
    temperature = "Non disponible";
    luminosity = "Non disponible";
  }

  Future<void> _fetchAndUpdateSensorData() async {
    String ledStatusTemperature =
        await fetchLedStatus(AppStrings.temperatureUrl);
    isTemperatureLedOn = ledStatusTemperature == "On";

    String ledStatusLuminosity = await fetchLedStatus(AppStrings.luminosityUrl);
    isLuminosityLedOn = ledStatusLuminosity == "On";

    var dataTemperature = await fetchData("temperature");
    var dataLuminosity = await fetchData("luminosity");

    sensorService.updateTemperatureLed(isTemperatureLedOn);
    sensorService.updateLuminosityLed(isLuminosityLedOn);

    sensorService.updateTemperatureSensor(
      double.parse(dataTemperature['temperature'].toString()),
      double.parse(dataTemperature['threshold'].toString()),
      dataTemperature['controlEnabled'] == true,
    );

    sensorService.updateLuminositySensor(
      double.parse(dataLuminosity['luminosity'].toString()),
      double.parse(dataLuminosity['threshold'].toString()),
      dataLuminosity['controlEnabled'] == true,
    );
  }

  @override
  void dispose() {
    sensorService.removeListener(_updateSensorData);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state); // Ajouter cet appel
    if (state == AppLifecycleState.resumed) {
      loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
            style: TextStyle(fontSize: 18), AppStrings.titleVisualizationPage),
      ),
      backgroundColor: AppColors.primaryColor,
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 12.0),
            _buildHorizontalButtonRow(),
            const SizedBox(height: 32.0),
            _buildCardSensor(context, temperatureSensor),
            _buildCardSensor(context, luminositySensor),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSensor(BuildContext context, Sensor sensor) {
    String data = "${sensor.valeur.toStringAsFixed(1)} ${sensor.unit}";
    String autoModeText =
        "Mode Automatique : " + (sensor.automatique ? "Activé" : "Désactivé");
    String lightStatusText =
        sensor.isLedOn ? AppStrings.lightOnStatus : AppStrings.lightOffStatus;

    return Card(
      color: AppColors.cardColor,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    sensor.type,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(sensor.icon, size: 32),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data.isNotEmpty ? data : AppStrings.loadingData,
              style: const TextStyle(
                color: AppColors.cardData,
                fontSize: 24,
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 6.0)),
            const Divider(),
            const Padding(padding: EdgeInsets.symmetric(vertical: 6.0)),
            Text(
              autoModeText,
              style: const TextStyle(
                fontSize: 14.0,
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
                  value: sensor.isLedOn,
                  onChanged: sensor.automatique
                      ? null
                      : (bool newValue) {
                          toggleLed(newValue, sensor.type, (bool newState) {
                            setState(() {
                              sensor.isLedOn = newState;
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
}
