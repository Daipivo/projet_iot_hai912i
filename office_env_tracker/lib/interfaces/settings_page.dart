import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
   _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: const Text('Paramètres'),
      ),
      body: const Center(
        // Ici, vous ajouteriez le contenu de votre écran de visualisation
         child: Text('Contenu de la page de paramètres'),
      ),
      
    );
  }
}
