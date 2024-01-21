import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/commons.dart';
import '../model/sensor.dart';
import '../services/api_service.dart';
import '../data/sensor_data.dart';
import '../services/firestore_service.dart';
import '../components/top_navigation_rooms.dart';
import 'dart:developer';
import '../services/api_service.dart';

class VisualizationPage extends StatefulWidget {
  @override
  VisualizationPageState createState() => VisualizationPageState();
}

class VisualizationPageState extends State<VisualizationPage>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> rooms = [];

  late FirestoreService firestoreService;

  bool isDataAvailable = true;

  Map<String, dynamic>? selectedRoom;

  String temperature = '';
  String luminosity = '';

  late Sensor temperatureSensor;
  late Sensor luminositySensor;

  bool isTemperatureLedOn = false;
  bool isLuminosityLedOn = false;

  late APIService apiService;

  final EdgeInsets elementPadding = const EdgeInsets.all(8.0);
  late final SensorData sensorData; // Utilisation d'une instance unique

  @override
  void initState() {
    super.initState();

    firestoreService = FirestoreService.instance;

    sensorData = SensorData();
    apiService = APIService.instance;

    temperatureSensor = sensorData.temperatureSensor;
    luminositySensor = sensorData.luminositySensor;

    sensorData.addListener(_updateSensorData);

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    bool isAuthenticated = await _signInAndFetchData();

    if (isAuthenticated) {
      await _loadRooms();
    } else {
      // Gérer le cas où l'utilisateur n'est pas authentifié
      // Par exemple, rediriger vers une page de connexion
    }
  }

  Future<bool> _signInAndFetchData() async {
    try {
      User? user = await FirestoreService.instance
          .signInWithEmail("test2@gmail.com", "test2-34");
      if (user != null) {
        log("Utilisateur connecté: ${user.email}");
        return true;
      }
    } catch (e) {
      print("Erreur lors de la tentative de connexion: $e");
    }
    return false;
  }

  Future<void> _loadRooms() async {
    rooms = await firestoreService.getRooms();
    selectedRoom = rooms[0];

    if (rooms.isNotEmpty) {
      selectedRoom = rooms[0];
      apiService.setUrlBase(selectedRoom!['ipAddress']);
      loadData();
    } else {
      print("Aucune salle disponible");
      setState(() {
        selectedRoom =
            null; // Assurez-vous que selectedRoom est null si aucune salle n'est disponible
      });
    }

    if (mounted) setState(() {});
  }

  void _updateSensorData() {
    setState(() {
      _setSensorData();
    });
  }

  void _setSensorData() {
    temperature = "${temperatureSensor.valeur.toStringAsFixed(1)}°C";
    luminosity = "${luminositySensor.valeur.toStringAsFixed(1)} V";
    isTemperatureLedOn =
        temperatureSensor.isLedOn; // Utilisez la valeur du capteur
    isLuminosityLedOn = luminositySensor.isLedOn;
    isDataAvailable = true;
  }

  Future<void> loadData() async {
    setState(() => _setLoadingState());

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
    isTemperatureLedOn = false;
    isLuminosityLedOn = false;
    isDataAvailable = false;
  }

  void _setErrorState() {
    setState(() {
      temperature = "Non disponible";
      luminosity = "Non disponible";
      isTemperatureLedOn = false;
      isLuminosityLedOn = false;
      isDataAvailable = false;
    });
  }

  Future<void> _fetchAndUpdateSensorData() async {
    String ledStatusTemperature =
        await apiService.fetchLedStatus(AppStrings.temperatureUrl);
    isTemperatureLedOn = ledStatusTemperature == "On";

    String ledStatusLuminosity =
        await apiService.fetchLedStatus(AppStrings.luminosityUrl);
    isLuminosityLedOn = ledStatusLuminosity == "On";

    var dataTemperature = await apiService.fetchData("temperature");
    var dataLuminosity = await apiService.fetchData("luminosity");

    sensorData.updateTemperatureLed(isTemperatureLedOn);
    sensorData.updateLuminosityLed(isLuminosityLedOn);

    sensorData.updateTemperatureSensor(
      double.parse(dataTemperature['temperature'].toString()),
      double.parse(dataTemperature['threshold'].toString()),
      dataTemperature['controlEnabled'] == true,
    );

    sensorData.updateLuminositySensor(
      double.parse(dataLuminosity['luminosity'].toString()),
      double.parse(dataLuminosity['threshold'].toString()),
      dataLuminosity['controlEnabled'] == true,
    );
  }

  @override
  void dispose() {
    sensorData.removeListener(_updateSensorData);
    WidgetsBinding.instance.removeObserver(this);
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
    String data;
    if (sensor.type == AppStrings.temperature) {
      data = temperature; // Utilisez directement la valeur de l'état
    } else {
      data = luminosity; // Utilisez directement la valeur de l'état
    }
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
                  value: (sensor.type == AppStrings.temperature)
                      ? isTemperatureLedOn
                      : isLuminosityLedOn,
                  onChanged: (!isDataAvailable || sensor.automatique)
                      ? null
                      : (bool newValue) {
                          apiService.toggleLed(newValue, sensor.type,
                              (bool newState) {
                            setState(() {
                              if (sensor.type == AppStrings.temperature) {
                                isTemperatureLedOn = newState;
                              } else {
                                isLuminosityLedOn = newState;
                              }
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
    if (selectedRoom == null) {
      return Container(); // Ou un widget approprié pour indiquer l'absence de données
    }

    return HorizontalRoomButtons(
      rooms: rooms,
      onRoomSelected: (Map<String, dynamic> room) {
        _onRoomSelected(room);
      },
      selectedRoom: selectedRoom!,
    );
  }

  void _onRoomSelected(Map<String, dynamic> room) {
    setState(() {
      selectedRoom = room;
      apiService.setUrlBase(room['ipAddress']);
      loadData();
    });
  }
}
