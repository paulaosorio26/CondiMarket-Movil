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
      print('Intentando conectar con: $baseUrl/api/auth/login');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(Duration(seconds: 15));

      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        String token = responseData['token'] ?? '';

        if (token.isNotEmpty) {
          await _guardarToken(token);

          // Buscar el usuario en la lista de usuarios usando el email
          final userData = await _buscarUsuarioPorEmail(email, token);

          if (userData != null) {
            await _guardarUsuario(userData);

            return {
              'success': true,
              'message': 'Inicio de sesión exitoso',
              'token': token,
              'user': userData,
            };

          } else {
            // Si no encontramos al usuario, crear datos básicos
            final basicUserData = {
              'id': DateTime.now().millisecondsSinceEpoch,
              'email': email,
              'nombre': email.split('@')[0],
              'name': email.split('@')[0], // Para compatibilidad
              'createdAt': DateTime.now().toIso8601String(),
            };

            await _guardarUsuario(basicUserData);

            return {
              'success': true,
              'message': 'Inicio de sesión exitoso',
              'token': token,
              'user': basicUserData,
            };
          }
        }

        return {
          'success': false,
          'message': 'Token no recibido del servidor',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Correo electrónico o contraseña incorrectos',
        };
      } else if (response.statusCode == 400) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          return {
            'success': false,
            'message': responseData['message'] ?? 'Datos de entrada inválidos',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Datos de entrada inválidos',
          };
        }
      } else {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          return {
            'success': false,
            'message': responseData['message'] ?? 'Error del servidor',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Error del servidor',
          };
        }
      }
    } catch (e) {
      print('Error al conectar con el backend: $e');

      if (e.toString().contains('TimeoutException')) {
        return {
          'success': false,
          'message': 'Tiempo de espera agotado. Verifique su conexión a internet.',
        };
      } else if (e.toString().contains('SocketException')) {
        return {
          'success': false,
          'message': 'No se pudo conectar al servidor. Verifique su conexión a internet.',
        };
      } else {
        return {
          'success': false,
          'message': 'Error de conexión. Intente nuevamente.',
        };
      }
    }
  }

  // Buscar usuario por email en la lista de usuarios
  Future<Map<String, dynamic>?> _buscarUsuarioPorEmail(String email, String token) async {
    try {
      print('Buscando usuario con email: $email');

      final response = await http.get(
        Uri.parse('$baseUrl/api/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      print('Respuesta de usuarios - Código: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<dynamic> usuarios = [];

        // La respuesta puede ser una lista directa o un objeto con una propiedad que contiene la lista
        if (responseData is List) {
          usuarios = responseData;
        } else if (responseData is Map) {
          // Buscar en diferentes propiedades posibles
          usuarios = responseData['users'] ??
              responseData['data'] ??
              responseData['content'] ??
              [];
        }

        print('Número de usuarios encontrados: ${usuarios.length}');

        // Buscar el usuario por email
        for (var usuario in usuarios) {
          if (usuario is Map<String, dynamic>) {
            String userEmail = usuario['email'] ?? '';
            if (userEmail.toLowerCase() == email.toLowerCase()) {
              print('Usuario encontrado: $usuario');
              return usuario;
            }
          }
        }

        print('Usuario no encontrado en la lista');
        return null;
      } else {
        print('Error al obtener usuarios: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al buscar usuario: $e');
      return null;
    }
  }

  // Verifica si hay sesión activa (simplificado)
  Future<bool> estaAutenticado() async {
    final token = await _obtenerToken();
    // En modo simplificado, solo verificamos si existe el token
    return token != null && token.isNotEmpty;
  }

  // Obtiene el usuario actual
  Future<Usuario?> obtenerUsuarioActual() async {
    try {
      final userData = await _obtenerUsuario();
      if (userData != null) {
        return Usuario.fromJson(userData);
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

  // Método para probar la conexión con el backend
  Future<bool> probarConexion() async {
    try {
      // Probamos con el endpoint de login sin datos para ver si responde
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': '', 'password': ''}),
      ).timeout(Duration(seconds: 5));

      // Si responde (aunque sea con error), significa que el servidor está activo
      return response.statusCode != 0;
    } catch (e) {
      print('Error al probar conexión: $e');
      return false;
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
          'name': 'Usuario de Prueba',
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
          'name': 'Administrador',
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