// services/product_service.dart

// 🌐 Servicio de productos.
// 🔌 Se encarga de obtener productos desde la API REST del backend.
// ✅ Si el backend responde correctamente, convierte los datos en una lista de objetos `Producto`.
// ⚠️ Si ocurre un error en la petición o el formato, lanza una excepción.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  // 🛠️ URL base del backend. Asegúrate de que esta URL esté activa.
  final String baseUrl = 'https://condimarket-backend.onrender.com';

  // 🔄 Método para obtener la lista de productos desde el backend
  Future<List<Producto>> obtenerProductos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/productos'));

      if (response.statusCode == 200) {
        // ✅ Decodifica la respuesta JSON y crea una lista de objetos Producto
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Producto.fromJson(json)).toList();
      } else {
        // ⚠️ Si no es 200, lanza una excepción con mensaje personalizado
        throw Exception('Error al cargar los productos');
      }
    } catch (e) {
      // ❌ Captura cualquier error de red o formato
      throw Exception('Error al obtener productos: $e');
    }
  }
}
