import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterAuthService {
  final String baseUrl = 'https://condimarket-backend.onrender.com';
  static const String USER_KEY = 'user_data';

  bool _usarDatosMock = false;

  RegisterAuthService({bool usarDatosMock = false}) {
    _usarDatosMock = usarDatosMock;
    print('🔧 RegisterAuthService inicializado - usarDatosMock: $_usarDatosMock');
  }

  Future<Map<String, dynamic>> registrarUsuario({
    required String nombre,
    required String email,
    required String password,
    // String? telefono,
    // String? direccion,
  }) async {
    print('📝 Iniciando registro de usuario...');
    print('   - Nombre: $nombre');
    print('   - Email: $email');
    print('   - Usar datos mock: $_usarDatosMock');

    if (_usarDatosMock) {
      print('🎭 Usando datos mock...');
      return await _simularRegistro(nombre, email, password);
    }

    print('🌐 Intentando conectar con el backend...');
    print('   - URL: $baseUrl/api/users');

    try {
      final requestBody = {
        'name': nombre,
        'email': email,
        'password': password,
        // 'telefono': telefono,
        // 'direccion': direccion,
      };

      print('📤 Enviando datos al backend:');
      print('   - Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/users'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print('📥 Respuesta del backend:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Headers: ${response.headers}');
      print('   - Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Registro exitoso en el backend');

        final Map<String, dynamic> userDto = jsonDecode(utf8.decode(response.bodyBytes));
        print('   - Datos recibidos: $userDto');

        // Convertir el ID a String si viene como número
        if (userDto['id'] is int || userDto['id'] is double) {
          userDto['id'] = userDto['id'].toString();
        }

        await guardarUsuario(userDto);

        return {
          'success': true,
          'message': 'Registro exitoso',
          'user': userDto,
        };
      } else {
        print('❌ Error en el backend - Status: ${response.statusCode}');

        Map<String, dynamic> errorResponse;
        try {
          errorResponse = jsonDecode(response.body);
        } catch (e) {
          print('   - Error parseando respuesta de error: $e');
          errorResponse = {'message': 'Error desconocido del servidor'};
        }

        return {
          'success': false,
          'message': errorResponse['message'] ?? 'Error en el registro - Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 Excepción al conectar con el backend: $e');
      print('🎭 Fallback a datos mock...');
      return await _simularRegistro(nombre, email, password);
    }
  }

  Future<Map<String, dynamic>> _simularRegistro(
      String nombre, String email, String password) async {
    print('🎭 Ejecutando simulación de registro...');

    final mockUsuarios = obtenerUsuariosMock();
    final existe = mockUsuarios.any((u) => u['email'] == email);

    if (existe) {
      print('   - Email ya existe en mock');
      return {
        'success': false,
        'message': 'El correo electrónico ya está registrado (offline)',
      };
    }

    final nuevoUsuario = {
      'id': 'mock-${DateTime.now().millisecondsSinceEpoch}',
      'name': nombre,
      'email': email,
      'createdAt': DateTime.now().toIso8601String(),
      // 'telefono': telefono,
      // 'direccion': direccion,
    };

    print('   - Usuario mock creado: $nuevoUsuario');
    await guardarUsuario(nuevoUsuario);

    return {
      'success': true,
      'message': 'Registro exitoso (offline)',
      'user': nuevoUsuario,
    };
  }

  List<Map<String, dynamic>> obtenerUsuariosMock() => [
    {
      'email': 'usuario@ejemplo.com',
      'password': '123456',
      'user': {
        'id': 'mock-001',
        'name': 'Usuario de Prueba',
        'email': 'usuario@ejemplo.com',
        'createdAt': DateTime.now().toIso8601String(),
      }
    },
  ];

  Future<void> guardarUsuario(Map<String, dynamic> userData) async {
    try {
      print('💾 Guardando usuario en SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(USER_KEY, jsonEncode(userData));
      print('   ✅ Usuario guardado exitosamente: ${userData['name']}');
    } catch (e) {
      print('   ❌ Error al guardar usuario: $e');
    }
  }

  Future<Map<String, dynamic>?> cargarUsuario() async {
    try {
      print('📖 Cargando usuario desde SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(USER_KEY);

      if (raw == null) {
        print('   - No hay usuario guardado');
        return null;
      }

      final usuario = jsonDecode(raw);
      print('   - Usuario cargado: $usuario');
      return usuario;
    } catch (e) {
      print('   ❌ Error al cargar usuario: $e');
      return null;
    }
  }

  Future<bool> tieneUsuarioGuardado() async {
    final usuario = await cargarUsuario();
    return usuario != null;
  }

  Future<void> limpiarUsuario() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(USER_KEY);
      print('🗑️ Datos de usuario eliminados');
    } catch (e) {
      print('❌ Error al eliminar datos de usuario: $e');
    }
  }

  // Método para verificar la conectividad con el backend
  Future<bool> verificarConexionBackend() async {
    try {
      print('🔍 Verificando conexión con el backend...');
      // Usar el endpoint que sabemos que existe: GET /api/users
      final response = await http.get(
        Uri.parse('$baseUrl/api/users'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('   - Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('   - Error: $e');
      return false;
    }
  }
}