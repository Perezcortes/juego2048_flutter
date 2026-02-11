import 'package:flutter/material.dart';
import 'screens/game_screen.dart'; // Importamos la pantalla principal

void main() {
  runApp(const Game2048App());
}

class Game2048App extends StatelessWidget {
  const Game2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '2048 Challenge',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const GameScreen(), // Llamamos a la pantalla separada
    );
  }
}
