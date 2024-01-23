import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/commons.dart';
import '../model/sensor.dart';
import '../services/api_service.dart';
import '../managers/sensor_manager.dart';
import '../services/firestore_service.dart';
import '../components/top_navigation_rooms.dart';
import 'dart:developer';
import '../services/api_service.dart';
import '../managers/room_manager.dart';
import '../model/room.dart';

class VisualizationPage extends StatefulWidget {
  @override
  VisualizationPageState createState() => VisualizationPageState();
}

class VisualizationPageState extends State<VisualizationPage>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> rooms = [];

  late FirestoreService firestoreService;

  bool isDataAvailable = true;

  String temperature = '';
  String luminosity = '';

  late Sensor temperatureSensor;
  late Sensor luminositySensor;

  bool isTemperatureLedOn = false;
  bool isLuminosityLedOn = false;

  late APIService apiService;

  final EdgeInsets elementPadding = const EdgeInsets.all(8.0);
  late final SensorManager sensorData;
  late final SelectedRoomManager selectedRoomManager;

  @override
  void initState() {
    super.initState();

    firestoreService = FirestoreService.instance;

    sensorData = SensorManager();
    selectedRoomManager = SelectedRoomManager();
    apiService = APIService.instance;

    temperatureSensor = sensorData.temperatureSensor;
    luminositySensor = sensorData.luminositySensor;

    sensorData.addListener(_updateSensorData);
    selectedRoomManager.addListener(_onSelectedRoomChanged);

    _onSelectedRoomChanged();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    bool isAuthenticated = await _signInAndFetchData();

    if (isAuthenticated) {
      await _loadRooms();
    } else {}
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

    if (rooms.isNotEmpty) {
      Room initialRoom = Room.fromJson(rooms[0]);
      selectedRoomManager.selectedRoom =
          initialRoom; // Utiliser SelectedRoomManager
      // Pas besoin de appeler loadData ici, car _onSelectedRoomChanged le fera
    } else {
      print("Aucune salle disponible");
      selectedRoomManager.selectedRoom = null;
    }
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Impossible de récupérer les données"),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _onSelectedRoomChanged() {
    var room = selectedRoomManager.selectedRoom;
    if (room != null) {
      apiService.setUrlBase(room.ipAddress);
      loadData();
    } else {}
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
    selectedRoomManager.removeListener(_onSelectedRoomChanged);
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
    if (rooms.isEmpty) {
      return Container(); // Ou un widget approprié pour indiquer l'absence de données
    }

    // Convertissez les rooms en List<Room> si nécessaire
    List<Room> roomObjects =
        rooms.map((roomData) => Room.fromJson(roomData)).toList();

    return HorizontalRoomButtons(
      rooms: roomObjects,
      onRoomSelected: _onRoomSelected,
      selectedRoom: selectedRoomManager.selectedRoom, // La salle sélectionnée
    );
  }

  void _onRoomSelected(Room room) {
    selectedRoomManager.selectedRoom = room;
  }
}
