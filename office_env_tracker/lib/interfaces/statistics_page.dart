import 'dart:developer';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/commons.dart';
import '../services/firestore_service.dart';
import '../components/top_navigation_rooms.dart';
import 'dart:math' hide log;
import '../services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late FirestoreService firestoreService;
  List<Map<String, dynamic>> rooms = [];
  List<Map<String, dynamic>> temperatureData = [];
  List<Map<String, dynamic>> luminosityData = [];

  late APIService apiService;

  Map<String, dynamic> selectedRoom = {};

  String selectedDataType = 'Température'; // Température, Luminosité, Tous
  final List<String> dataTypes = ['Température', 'Luminosité'];

  @override
  void initState() {
    super.initState();

    firestoreService = FirestoreService.instance;
    _loadRooms();
  }

  Future<void> _handleRefreshData() async {
    try {
      if (rooms.isNotEmpty) {
        if (selectedDataType == "Température") {
          temperatureData = await firestoreService.getSensorDataByRoomId(
              selectedDataType, selectedRoom['id']);
        } else {
          luminosityData = await firestoreService.getSensorDataByRoomId(
              selectedDataType, selectedRoom['id']);
        }
        setState(() {}); // Mettez à jour l'état pour rafraîchir le graphique
      }
    } catch (e) {}
  }

  void _signInAndFetchData() async {
    await FirestoreService.instance.signInWithEmail(
      "test@gmail.com",
      "test",
    );
  }

  Future<void> _loadRooms() async {
    rooms = await firestoreService.getRooms();
    selectedRoom = rooms[0];
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = selectedDataType == 'Température'
        ? generateSpots(temperatureData)
        : generateSpots(luminosityData);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Visualiser les statistiques environnementales', // Replace with your title
          style: TextStyle(fontSize: 18),
        ),
      ),
      backgroundColor: AppColors.primaryColor,
      body: RefreshIndicator(
        onRefresh: _handleRefreshData,
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 12.0),
            _buildHorizontalButtonRow(),
            const SizedBox(height: 46.0),
            _buildDataTypeSelector(),
            const SizedBox(height: 46.0),
            Container(
              height: 300,
              padding: EdgeInsets.all(16),
              child: spots.isNotEmpty
                  ? buildChart(spots, selectedDataType)
                  : Center(child: Text('Aucune donnée à afficher')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalButtonRow() {
    return HorizontalRoomButtons(
      rooms: rooms,
      onRoomSelected: (Map<String, dynamic> room) {
        _onRoomSelected(room);
      },
      selectedRoom: selectedRoom,
    );
  }

  Widget _buildDataTypeSelector() {
    // Obtenir la largeur de l'écran
    double screenWidth = MediaQuery.of(context).size.width;

    return ToggleButtons(
      isSelected: dataTypes.map((type) => selectedDataType == type).toList(),
      onPressed: (int index) {
        setState(() {
          selectedDataType = dataTypes[index];
          _handleRefreshData();
        });
      },
      children: dataTypes.map((type) {
        // Calculer la largeur de chaque bouton
        return Container(
          width: screenWidth / dataTypes.length -
              2, // La moitié de la largeur de l'écran pour chaque bouton
          alignment: Alignment.center,
          child: Text(type),
        );
      }).toList(),
      // Ajoutez ici des options de personnalisation (couleurs, bordures, etc.)
    );
  }

  Widget buildChart(List<FlSpot> spots, String title) {
    double minY = 0, maxY = 0;

    if (selectedDataType == 'Température') {
      minY = spots.map((spot) => spot.y).reduce(min) - 1;
      maxY =
          min(spots.map((spot) => spot.y).reduce(max).ceil().toDouble(), 40.0);
    } else {
      minY = 0.0; // Limite inférieure fixe pour la luminosité
      maxY = 3.5; // Limite supérieure fixe pour la luminosité
    }

    double intervalY = (maxY - minY) / 3.ceil().toDouble();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: intervalY, // Augmentez cet intervalle si nécessaire
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value == minY || (value - minY) > intervalY) {
                  return Text(value.toStringAsFixed(1));
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (spots.length / 4)
                  .round()
                  .toDouble(), // Calculez l'intervalle
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(value.toInt().toString());
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: spots.first.x,
        maxX: spots.last.x,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  void _onRoomSelected(Map<String, dynamic> room) {
    setState(() {
      selectedRoom = room;
      apiService.setUrlBase(room['ipAddress']);
      _handleRefreshData();
    });
  }

  List<FlSpot> generateSpots(List<Map<String, dynamic>> data) {
    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      double yValue = data[i]['value'];
      spots.add(FlSpot(i.toDouble(), yValue));
    }
    return spots;
  }
}
