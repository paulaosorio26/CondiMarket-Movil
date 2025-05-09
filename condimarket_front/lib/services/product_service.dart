// services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  // URL base del backend
  final String baseUrl = 'https://condimarket-backend.onrender.com';

  // Método para obtener la lista de productos desde el backend
  Future<List<Producto>> obtenerProductos() async {
    try {
      // Añadimos un timeout para que no espere indefinidamente
      final response = await http.get(
        Uri.parse('$baseUrl/api/productos'),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Decodifica la respuesta JSON y crea una lista de objetos Producto
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Producto.fromJson(json)).toList();
      } else {
        // Si la respuesta no es 200, imprimimos el código para depuración
        print('Error en la respuesta: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        throw Exception('Error al cargar los productos: Código ${response.statusCode}');
      }
    } catch (e) {
      // Captura cualquier error de red o formato y lo relanza
      print('Error al conectar con el backend: $e');
      throw Exception('Error al obtener productos: $e');
    }
  }

  // Método para obtener un producto específico por su ID
  Future<Producto> obtenerProductoPorId(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/productos/$id'),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Decodifica la respuesta JSON y crea un objeto Producto
        Map<String, dynamic> data = json.decode(response.body);
        return Producto.fromJson(data);
      } else {
        throw Exception('Error al cargar el producto: Código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener el producto: $e');
    }
  }

  // Método para obtener las categorías disponibles
  Future<List<String>> obtenerCategorias() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/categorias'),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Decodifica la respuesta JSON
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item['nombre'].toString()).toList();
      } else {
        throw Exception('Error al cargar categorías: Código ${response.statusCode}');
      }
    } catch (e) {
      // Si hay un error, retornamos una lista vacía para que la app no se rompa
      print('Error al obtener categorías: $e');
      return [];
    }
  }
}