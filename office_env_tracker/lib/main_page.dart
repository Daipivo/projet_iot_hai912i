import 'package:flutter/material.dart';
import 'settings_page.dart'; // Assurez-vous d'importer vos pages ici
import 'visualization_page.dart';
import 'bottom_navigation.dart';
import 'statistics_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Index initial pour la page sélectionnée

  // Ajoutez toutes vos pages ici
  final List<Widget> _pages = [
    SettingsPage(),
    VisualizationPage(),
    StatisticsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
