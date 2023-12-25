import 'package:flutter/material.dart';

class StatisticsPage extends StatefulWidget {
  @override
   _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: const Text('Statistiques'),
      ),
      body: const Center(
        // Ici, vous ajouteriez le contenu de votre écran de visualisation
         child: Text('Contenu de la page de statistiques'),
      ),
    );
  }
}
