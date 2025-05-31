import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class CartHttpService {
  static const String baseUrl = 'https://condimarket-backend.onrender.com/api/cart';

  // Variable estática para almacenar las cookies (JSESSIONID)
  static String? _sessionCookie;

  // Método para extraer cookies de la respuesta
  static void _extractCookies(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      // Extraer solo el JSESSIONID
      int index = rawCookie.indexOf(';');
      _sessionCookie = (index == -1) ? rawCookie : rawCookie.substring(0, index);
      print('Cookie extraída: $_sessionCookie');
    }
  }

  // Método para crear headers con cookies
  static Map<String, String> _getHeaders() {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Flutter App',
    };

    // Agregar cookie si existe
    if (_sessionCookie != null) {
      headers['Cookie'] = _sessionCookie!;
      print('Enviando con cookie: $_sessionCookie');
    }

    return headers;
  }

  // ✅ Método mejorado para manejar errores de conexión
  static Future<bool> _handleHttpResponse(http.Response response, String operation) async {
    print('$operation response: ${response.statusCode} - ${response.body}');

    // Extraer cookies de todas las respuestas
    _extractCookies(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 500) {
      print('Server error for $operation, attempting session refresh...');
      // En caso de error de servidor, limpiar sesión y reintentar una vez
      _sessionCookie = null;
      return false; // El método que llame debe manejar el retry
    } else {
      print('Failed $operation: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  // Agregar producto al carrito
  static Future<bool> addToCart(Producto product, int quantity) async {
    try {
      print('Adding to cart: ${product.nombre} x$quantity');

      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: _getHeaders(),
        body: jsonEncode({
          'productId': product.id,
          'productName': product.nombre,
          'price': product.precio,
          'quantity': quantity,
          'imageUrl': product.imagenUrl,
          'category': product.categoria,
          'description': product.descripcion, // ✅ Incluir descripción
        }),
      ).timeout(Duration(seconds: 10)); // ✅ Timeout para evitar cuelgues

      return await _handleHttpResponse(response, 'Add to cart');
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  // ✅ NUEVO: Método para actualizar cantidad específica
  static Future<bool> updateQuantity(String productId, int newQuantity) async {
    try {
      print('Updating quantity for product $productId to $newQuantity');

      final response = await http.put(
        Uri.parse('$baseUrl/update/$productId'),
        headers: _getHeaders(),
        body: jsonEncode({
          'quantity': newQuantity,
        }),
      ).timeout(Duration(seconds: 10));

      final success = await _handleHttpResponse(response, 'Update quantity');

      if (!success && response.statusCode == 500) {
        // Retry con sesión limpia
        print('Retrying update quantity with fresh session...');
        final retryResponse = await http.put(
          Uri.parse('$baseUrl/update/$productId'),
          headers: _getHeaders(),
          body: jsonEncode({
            'quantity': newQuantity,
          }),
        ).timeout(Duration(seconds: 10));

        return await _handleHttpResponse(retryResponse, 'Update quantity (retry)');
      }

      return success;
    } catch (e) {
      print('Error updating quantity: $e');
      return false;
    }
  }

  // Obtener items del carrito
  static Future<List<Map<String, dynamic>>> getCartItems() async {
    try {
      print('Fetching cart items...');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: _getHeaders(),
      ).timeout(Duration(seconds: 10));

      print('GET Cart status: ${response.statusCode}');

      // Extraer cookies de la respuesta
      _extractCookies(response);

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('Cart response body: $responseBody');

        if (responseBody.isEmpty || responseBody == 'null') {
          print('Empty cart response');
          return [];
        }

        try {
          final List<dynamic> data = jsonDecode(responseBody);
          print('Parsed ${data.length} cart items');
          return data.cast<Map<String, dynamic>>();
        } catch (e) {
          print('Error parsing cart JSON: $e');
          return [];
        }
      } else {
        print('Failed to get cart items: ${response.statusCode}');
      }

      return [];
    } catch (e) {
      print('Error getting cart items: $e');
      return [];
    }
  }

  // Eliminar producto del carrito
  static Future<bool> removeFromCart(String productId) async {
    try {
      print('Removing product $productId from cart');

      final response = await http.delete(
        Uri.parse('$baseUrl/remove/$productId'),
        headers: _getHeaders(),
      ).timeout(Duration(seconds: 10));

      final success = await _handleHttpResponse(response, 'Remove from cart');

      if (!success && response.statusCode == 500) {
        // Retry con sesión limpia
        print('Retrying remove with fresh session...');
        final retryResponse = await http.delete(
          Uri.parse('$baseUrl/remove/$productId'),
          headers: _getHeaders(),
        ).timeout(Duration(seconds: 10));

        return await _handleHttpResponse(retryResponse, 'Remove from cart (retry)');
      }

      return success;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  // Limpiar carrito
  static Future<bool> clearCart() async {
    try {
      print('Clearing cart...');

      final response = await http.post(
        Uri.parse('$baseUrl/clear'),
        headers: _getHeaders(),
      ).timeout(Duration(seconds: 10));

      return await _handleHttpResponse(response, 'Clear cart');
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  // ✅ Método para verificar el estado de la sesión
  static Future<bool> checkSession() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status'),
        headers: _getHeaders(),
      ).timeout(Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Error checking session: $e');
      return false;
    }
  }

  // Método para limpiar la sesión (logout)
  static void clearSession() {
    _sessionCookie = null;
    print('Sesión limpiada');
  }

  // ✅ Método para debug - obtener info de sesión actual
  static String? getCurrentSession() {
    return _sessionCookie;
  }
}