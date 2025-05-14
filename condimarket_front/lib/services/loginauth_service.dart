import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class LoginAuthService {
  // URL base del backend
  final String baseUrl = 'https://condimarket-backend.onrender.com';

  // Claves para SharedPreferences
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_KEY = 'user_data';

  // Modo mock
  bool _usarDatosMock = false;

  LoginAuthService({bool usarDatosMock = false}) {
    _usarDatosMock = usarDatosMock;
  }

  // Iniciar sesión
  Future<Map<String, dynamic>> iniciarSesion({
    required String email,
    required String password,
  }) async {
    if (_usarDatosMock) {
      return _simularInicioSesion(email, password);
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(Duration(seconds: 15));

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        String token = responseData['token'] ?? '';

        if (token.isNotEmpty) {
          await _guardarToken(token);
          await _guardarUsuario(responseData['user']);
        }

        return {
          'success': true,
          'message': 'Inicio de sesión exitoso',
          'token': token,
          'user': responseData['user'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error en el inicio de sesión',
        };
      }
    } catch (e) {
      print('Error al conectar con el backend: $e. Usando datos quemados...');
      return _simularInicioSesion(email, password);
    }
  }

  // Simulación de inicio de sesión (modo offline)
  Map<String, dynamic> _simularInicioSesion(String email, String password) {
    final mockUsuarios = [
      {
        'email': 'usuario@ejemplo.com',
        'password': '123456',
        'user': {
          'id': 'mock-user-001',
          'nombre': 'Usuario de Prueba',
          'email': 'usuario@ejemplo.com',
          'telefono': '123456789',
          'direccion': 'Calle Principal 123',
          'rol': 'cliente',
          'createdAt': DateTime.now().toIso8601String(),
        }
      },
      {
        'email': 'admin@ejemplo.com',
        'password': 'admin123',
        'user': {
          'id': 'mock-admin-001',
          'nombre': 'Administrador',
          'email': 'admin@ejemplo.com',
          'telefono': '987654321',
          'direccion': 'Avenida Central 456',
          'rol': 'admin',
          'createdAt': DateTime.now().toIso8601String(),
        }
      },
    ];

    final usuario = mockUsuarios.firstWhere(
          (u) => u['email'] == email && u['password'] == password,
      orElse: () => {
        'email': '',
        'password': '',
        'user': {},
      },
    );

    if ((usuario['user'] as Map).isNotEmpty) {
      final mockToken = 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}';
      _guardarToken(mockToken);
      _guardarUsuario(usuario['user'] as Map<String, dynamic>);

      return {
        'success': true,
        'message': 'Inicio de sesión exitoso (modo offline)',
        'token': mockToken,
        'user': usuario['user'],
      };
    } else {
      return {
        'success': false,
        'message': 'Correo electrónico o contraseña incorrectos',
      };
    }
  }

  // Verifica si hay sesión activa
  Future<bool> estaAutenticado() async {
    final token = await _obtenerToken();
    return token != null && token.isNotEmpty;
  }

  // Obtiene el usuario actual
  Future<Usuario?> obtenerUsuarioActual() async {
    try {
      final token = await _obtenerToken();
      if (token == null || token.isEmpty) return null;

      final userData = await _obtenerUsuario();
      if (userData != null) return Usuario.fromJson(userData);

      if (_usarDatosMock) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        await _guardarUsuario(responseData['user']);
        return Usuario.fromJson(responseData['user']);
      }

      return null;
    } catch (e) {
      print('Error al obtener usuario actual: $e');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
    await prefs.remove(USER_KEY);
  }

  // SharedPreferences helpers
  Future<void> _guardarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
  }

  Future<String?> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(TOKEN_KEY);
  }

  Future<void> _guardarUsuario(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_KEY, json.encode(userData));
  }

  Future<Map<String, dynamic>?> _obtenerUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(USER_KEY);
    if (userData != null) {
      return json.decode(userData) as Map<String, dynamic>;
    }
    return null;
  }
}
