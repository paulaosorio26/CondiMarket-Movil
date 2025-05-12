import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  // URL base del backend
  final String baseUrl = 'https://condimarket-backend.onrender.com';

  // Clave para almacenar el token en SharedPreferences
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_KEY = 'user_data';

  // Bandera para usar datos mock (quemados) en caso de que el backend no esté disponible
  bool _usarDatosMock = false;

  // Constructor con opción para usar datos quemados
  AuthService({bool usarDatosMock = false}) {
    _usarDatosMock = usarDatosMock;
  }

  // Método para iniciar sesión
  Future<Map<String, dynamic>> iniciarSesion({
    required String email,
    required String password,
  }) async {
    // Si estamos usando datos mock, simulamos el inicio de sesión
    if (_usarDatosMock) {
      return _simularInicioSesion(email, password);
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(Duration(seconds: 15));

      // Decodificar la respuesta
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Login exitoso
        String token = responseData['token'] ?? '';

        // Guardar el token en SharedPreferences
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
        // Error en el login
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error en el inicio de sesión',
        };
      }
    } catch (e) {
      print('Error al conectar con el backend: $e. Usando datos quemados...');
      // Si falla la conexión con el backend, intentamos con datos mock
      return _simularInicioSesion(email, password);
    }
  }

  // Método para simular inicio de sesión con datos quemados
  Map<String, dynamic> _simularInicioSesion(String email, String password) {
    // Datos de usuario de prueba
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

    // Buscar usuario con las credenciales proporcionadas
    final usuario = mockUsuarios.firstWhere(
          (u) => u['email'] == email && u['password'] == password,
      orElse: () => {
        'email': '',
        'password': '',
        'user': {}, // o cualquier objeto no nulo
      },
    );


    if (usuario['user'] != null) {
      // Generar un token falso
      final mockToken = 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}';

      // Guardar datos en SharedPreferences
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

  // Verificar si hay una sesión activa
  Future<bool> estaAutenticado() async {
    final token = await _obtenerToken();
    return token != null && token.isNotEmpty;
  }

  // Obtener el usuario actual
  Future<Usuario?> obtenerUsuarioActual() async {
    try {
      // Primero verificamos si hay un token guardado
      final token = await _obtenerToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      // Intentamos obtener el usuario guardado localmente
      final userData = await _obtenerUsuario();
      if (userData != null) {
        return Usuario.fromJson(userData);
      }

      // Si estamos en modo mock o no hay conexión, devolvemos null
      if (_usarDatosMock) {
        return null;
      }

      // Si no hay datos locales, consultamos al backend
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/api/auth/me'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          // Guardamos los datos para la próxima vez
          await _guardarUsuario(responseData['user']);
          return Usuario.fromJson(responseData['user']);
        } else {
          return null;
        }
      } catch (e) {
        print('Error al conectar con el backend: $e');
        return null;
      }
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

  // Método para guardar el token en SharedPreferences
  Future<void> _guardarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
  }

  // Método para obtener el token de SharedPreferences
  Future<String?> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(TOKEN_KEY);
  }

  // Método para guardar los datos del usuario en SharedPreferences
  Future<void> _guardarUsuario(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_KEY, json.encode(userData));
  }

  // Método para obtener los datos del usuario de SharedPreferences
  Future<Map<String, dynamic>?> _obtenerUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(USER_KEY);
    if (userData != null) {
      return json.decode(userData) as Map<String, dynamic>;
    }
    return null;
  }
}