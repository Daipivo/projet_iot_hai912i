import 'package:flutter/material.dart';
import 'main_page.dart';


void main() {
  runApp(MyApp()); // Retirez 'const' ici.
}

class MyApp extends StatelessWidget {
  // Le constructeur peut rester constant si rien à l'intérieur ne change.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MainPage(), // Changez cela pour pointer vers votre page de visualisation.
    );
  }
}

// Reste de votre code MyHomePage si nécessaire...
