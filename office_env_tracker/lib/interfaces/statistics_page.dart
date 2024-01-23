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
import '../managers/room_manager.dart';
import '../model/room.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late FirestoreService firestoreService;

  String selectedDataType = 'Température';
  List<Map<String, dynamic>> sensorDataList = [];

  late final SelectedRoomManager selectedRoomManager;

  @override
  void initState() {
    super.initState();
    firestoreService = FirestoreService.instance;
    selectedRoomManager = SelectedRoomManager();
    _handleRefreshData();
  }

  Future<void> _handleRefreshData() async {
    Room? selectedRoom = selectedRoomManager.selectedRoom;
    if (selectedRoom != null) {
      try {
        sensorDataList = await firestoreService.getSensorDataByRoomId(
            selectedDataType, selectedRoom.id);
        setState(() {});
      } catch (e) {
        log("Erreur lors du chargement des données : $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Impossible de récupérer les données statistiques"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = generateSpots();
    String roomName =
        selectedRoomManager.selectedRoom?.name ?? "Aucun bureau sélectionné";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Visualiser les statistiques environnementales',
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
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Bureau sélectionné : $roomName",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              height: 300,
              padding: EdgeInsets.all(16),
              child: spots.isNotEmpty
                  ? buildChart(spots, selectedDataType)
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SvgPicture.asset(
                            'images/not_found.svg', // Assurez-vous que le chemin est correct
                            width: 300,
                          ),
                          const Text('Aucune donnée à afficher !'),
                        ],
                      ),
                    ),
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
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Commons.buildButton(
              context,
              'Température',
              Icons.thermostat,
              () => _onDataTypeSelected('Température'),
              selectedDataType == 'Température',
              width: MediaQuery.of(context).size.width / 2.25,
            ),
            const SizedBox(width: 20.0),
            Commons.buildButton(
              context,
              'Luminosité',
              Icons.lightbulb_outline,
              () => _onDataTypeSelected('Luminosité'),
              selectedDataType == 'Luminosité',
              width: MediaQuery.of(context).size.width / 2.25,
            ),
          ],
        ),
      ),
    );
  }

  void _onDataTypeSelected(String dataType) {
    setState(() {
      selectedDataType = dataType;
      _handleRefreshData();
    });
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

  List<FlSpot> generateSpots() {
    return sensorDataList.asMap().entries.map((entry) {
      double x = entry.key.toDouble();
      double y = entry.value['value'];
      return FlSpot(x, y);
    }).toList();
  }
}
