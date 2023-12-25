import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/network_utils.dart';
import '../utils/app_theme.dart';

class VisualizationPage extends StatefulWidget {
  
  
  @override
  VisualizationPageState createState() => VisualizationPageState();
}

class VisualizationPageState extends State<VisualizationPage> with WidgetsBindingObserver{
  
  String selectedRoom = 'Bureau 1';
  bool isLightOn = false;

  String temperature = '';
  String luminosity = '';

  final EdgeInsets elementPadding = const EdgeInsets.all(8.0);

 @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state); // Ajouter cet appel
    if (state == AppLifecycleState.resumed) {
      log("Resume");
      loadData(); // Charger les données lorsque l'application est reprise
    }
  }

  Future<void> loadData() async {
    
    log('Chargement des données...');

    setState(() {
      temperature = AppStrings.loadingData; 
      luminosity = AppStrings.loadingData;  
    });

    try {
    temperature = await fetchTemperature();
    log('Température chargée: $temperature');
    luminosity = await fetchLuminosity();
    log('Luminosité chargée: $luminosity');
  } catch (e) {
    log('Erreur lors du chargement des données: $e');
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
          style : 
          TextStyle(
            fontSize:18
          ),
          AppStrings.titleVisualizationPage),
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
          
          _buildCard(context, AppStrings.temperatureTitleCard, temperature, Icons.thermostat_outlined),
          
          const SizedBox(height: 18.0),

          _buildCard(context, AppStrings.luminosityTitleCard, luminosity, Icons.wb_sunny_outlined),
                    
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
        _buildRoomButton(context, 'Bureau 1'),
        SizedBox(width: 10.0),
        _buildRoomButton(context, 'Bureau 2'),
        SizedBox(width: 10.0),
        _buildRoomButton(context, 'Bureau 3'),
        SizedBox(width: 10.0),
        _buildRoomButton(context, 'Bureau 4'),
      ],
    ),
  );
}


  Widget _buildRoomButton(BuildContext context, String roomName) {

    bool isSelected = selectedRoom == roomName;

    return ElevatedButton(
      onPressed: () {
      loadData();
      selectedRoom = roomName;
      setState(() {
      });
      },

    style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.buttonSelectedColor : AppColors.buttonUnselectedColor, // Changer la couleur de fond si sélectionné
      ),
      child: Text(
      roomName,
      style: const TextStyle(
        color: Colors.black,
        ),
      ),
    );
  }

Widget _buildCard(BuildContext context, String title, String data, IconData icon) {
  return Card(
    color: AppColors.cardColor,
    margin: const EdgeInsets.all(10),
    child: Container(
      padding: elementPadding,
      width: double.infinity,
      height: 120.0, // Ajustez la hauteur selon la taille de votre contenu
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: elementPadding,
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Positioned(
            top: elementPadding.top,
            right: elementPadding.right,
            child: Icon(icon, size: 32), // Taille de l'icône
          ),
          Positioned(
            bottom: elementPadding.bottom,
            left: elementPadding.left,
            child: Text(
              data.isNotEmpty ? data : 'Chargement...',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



Widget _buildLightStatus(BuildContext context) {
  
    String lightStatusText = isLightOn ? AppStrings.lightOnStatus : AppStrings.lightOffStatus; // Utiliser une condition ici
  
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
            Padding(
              padding:  EdgeInsets.only(bottom: 8.0),
              child:  Text(
                AppStrings.stateLight,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
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
                  onChanged: (bool newValue) {
                    setState(() {

                      isLightOn = newValue;
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

Future<String> fetchTemperature() async {
    return fetchData('http://192.168.4.1/temperature', 'temperature');
}

Future<String> fetchLuminosity() async {
    return fetchData('http://192.168.4.1/luminosite', 'luminosite');
}
