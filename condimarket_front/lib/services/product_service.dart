import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  final String baseUrl = 'https://condimarket-backend.onrender.com';

  Future<List<Producto>> fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/products'))
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        // decode con utf8 para evitar problemas con acentos o caracteres especiales
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        return data.map((json) => Producto.fromJson(json)).toList();
      } else {
        print('Backend error: ${response.statusCode}');
        print('Body: ${response.body}');
        throw Exception('Error loading products');
      }
    } catch (e) {
      print('Backend failed: $e');
      return Producto.getMockProducts();
    }
  }

  Future<Producto> fetchProductById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/productos/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return Producto.fromJson(data);
      } else {
        throw Exception('Error loading product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product by ID: $e');
    }
  }

  Future<List<String>> fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/categorias'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        // Suponemos que la clave para el nombre de categoría es 'category'
        return data.map((item) => item['category'].toString()).toList();
      } else {
        throw Exception('Error loading categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }
}
