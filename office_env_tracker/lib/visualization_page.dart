import 'package:flutter/material.dart';

class VisualizationPage extends StatefulWidget {
  @override
  VisualizationPageState createState() => VisualizationPageState();
}

class VisualizationPageState extends State<VisualizationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualisation'),
        actions: [
          // Ajoutez des actions si nécessaire
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Créer la rangée pour les boutons "Bur. 1", "Bur. 2", "Bur. 3"
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildRoomButton(context, 'Bur. 1'),
                  _buildRoomButton(context, 'Bur. 2'),
                  _buildRoomButton(context, 'Bur. 3'),
                ],
              ),
            ),
            // Créer la carte pour la température
            _buildCard(context, 'Température :', '20°C', Icons.thermostat_outlined),
            // Créer la carte pour la luminosité
            _buildCard(context, 'Luminosité :', '3.3V', Icons.wb_sunny_outlined),
            // Créer la section pour l'état de la lumière
            _buildLightStatus(context, 'La lumière est activée', true), // true si allumée, false si éteinte
          ],
        ),
      ),
    );
  }

  Widget _buildRoomButton(BuildContext context, String roomName) {
    return ElevatedButton(
      onPressed: () {
        // Ajoutez votre logique pour gérer les appuis sur les boutons
      },
      child: Text(roomName),
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).colorScheme.secondaryContainer, // Couleur du bouton
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Icon(icon),
          ],
        ),
      ),
    );
  }

  Widget _buildLightStatus(BuildContext context, String status, bool isLightOn) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text('État de la lumière :'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(status),
            Icon(
              isLightOn ? Icons.lightbulb : Icons.lightbulb_outline,
              color: isLightOn ? Colors.yellow : null,
            ),
          ],
        ),
      ),
    );
  }
}
