import 'package:flutter/material.dart';
import 'screens/register_screen.dart';

void main() {
  // Asegurarse de que la inicialización de Flutter se complete
  WidgetsFlutterBinding.ensureInitialized();

  runApp(RegisterMain());
}

class RegisterMain extends StatelessWidget {
  const RegisterMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CondiMarket',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Personalización adicional del tema
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue[700],
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      // Comenzamos directamente con la pantalla de registro
      home: RegisterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}