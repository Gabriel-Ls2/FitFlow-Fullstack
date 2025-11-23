import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitFlow',
      debugShowCheckedModeBanner: false,
      // Configuração do Tema Escuro
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117), // Fundo quase preto
        cardColor: const Color(0xFF161B22), // Fundo dos cards
        primaryColor: const Color(0xFF238636), // Verde do botão
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF238636),
          secondary: Color(0xFF58A6FF), // Azul claro
        ),
      ),
      home: const LoginScreen(),
    );
  }
}