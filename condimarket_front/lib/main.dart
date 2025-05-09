import 'package:flutter/material.dart';
//import 'screens/login_screen.dart';       // Importa el login
import 'screens/catalogo_screen.dart';    // Importa el catálogo si luego lo usarás

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CondiMarket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
//      home: const LoginScreen(),
    );
  }
}
