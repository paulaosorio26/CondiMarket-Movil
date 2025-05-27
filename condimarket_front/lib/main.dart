import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Servicios
import 'services/cart_service.dart';
import 'services/payment_service.dart';

// Pantallas
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/catalogo_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/payment_screen.dart'; // Nueva pantalla de pago

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientación vertical fija
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Barra de estado transparente con iconos oscuros
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      primaryColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.orange,
        primary: Colors.orange,
      ),
      scaffoldBackgroundColor: Colors.white,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Roboto',

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // TextButton (enlaces, etc.)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue[700],
        ),
      ),

      // Estilo de campos de texto
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
        Provider(create: (_) => PaymentService()),
      ],
      child: MaterialApp(
        title: 'CondiMarket',
        debugShowCheckedModeBanner: false,
        theme: baseTheme,
        initialRoute: '/register',
        onGenerateRoute: (settings) {
          if (settings.name == '/payment') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => PaymentScreen(
                totalAmount: args['totalAmount'],
                cartItems: args['cartItems'],
              ),
            );
          }

          switch (settings.name) {
            case '/register':
              return MaterialPageRoute(builder: (_) => const RegisterScreen());
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/catalogo':
              return MaterialPageRoute(builder: (_) => CatalogoScreen());
            case '/cart':
              return MaterialPageRoute(builder: (_) => const CartScreen());
            default:
              return MaterialPageRoute(builder: (_) => const RegisterScreen());
          }
        },
      ),
    );
  }
}
