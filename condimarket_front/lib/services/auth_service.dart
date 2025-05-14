import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  // MÉTODO PARA REGISTRAR USUARIO
  Future<Map<String, dynamic>> registrarUsuario({
    required String nombre,
    required String email,
    required String password,
    String? telefono,
    String? direccion,
  }) async {
    // Si estamos usando datos mock, simulamos el registro
    if (_usarDatosMock) {
      return _simularRegistro(nombre, email, password, telefono, direccion);
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'email': email,
          'password': password,
          'telefono': telefono,
          'direccion': direccion,
        }),
      ).timeout(Duration(seconds: 15));

      // Decodificar la respuesta
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        // Registro exitoso
        String token = responseData['token'] ?? '';

        // Guardar el token en SharedPreferences
        if (token.isNotEmpty) {
          await _guardarToken(token);
          await _guardarUsuario(responseData['user']);
        }

        return {
          'success': true,
          'message': 'Registro exitoso',
          'token': token,
          'user': responseData['user'],
        };
      } else {
        // Error en el registro
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error en el registro',
        };
      }
    } catch (e) {
      print('Error al conectar con el backend: $e. Usando datos quemados...');
      // Si falla la conexión con el backend, intentamos con datos mock
      return _simularRegistro(nombre, email, password, telefono, direccion);
    }
  }

  // MÉTODO PARA SIMULAR REGISTRO CON DATOS QUEMADOS
  Map<String, dynamic> _simularRegistro(
      String nombre,
      String email,
      String password,
      String? telefono,
      String? direccion,
      ) {
    // Verificar si el email ya está registrado en los datos mock
    final mockUsuarios = _obtenerUsuariosMock();

    // Verificar si el email ya existe
    final usuarioExistente = mockUsuarios.any((u) => u['email'] == email);

    if (usuarioExistente) {
      return {
        'success': false,
        'message': 'El correo electrónico ya está registrado',
      };
    }

    // Crear un nuevo ID para el usuario
    final nuevoId = 'mock-user-${DateTime.now().millisecondsSinceEpoch}';

    // Crear datos del nuevo usuario
    final nuevoUsuario = {
      'id': nuevoId,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'rol': 'cliente', // Por defecto, es cliente
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Generar un token falso
    final mockToken = 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}';

    // Guardar datos en SharedPreferences
    _guardarToken(mockToken);
    _guardarUsuario(nuevoUsuario);

    return {
      'success': true,
      'message': 'Registro exitoso (modo offline)',
      'token': mockToken,
      'user': nuevoUsuario,
    };
  }

  // OBTENER USUARIOS MOCK
  List<Map<String, dynamic>> _obtenerUsuariosMock() {
    return [
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
  }

  // MÉTODOS AUXILIARES PARA MANEJAR TOKENS Y USUARIO
  // Método para guardar el token en SharedPreferences
  Future<void> _guardarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
  }

  // Método para guardar los datos del usuario en SharedPreferences
  Future<void> _guardarUsuario(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_KEY, json.encode(userData));
  }
}