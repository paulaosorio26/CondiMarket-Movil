// models/product_model.dart

// 🔧 Modelo de datos de producto.
// 📦 Define la estructura del producto tal como se espera del backend.
// 🧪 Actualmente simula algunos productos desde un método local mientras se conecta el backend real.

class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl;
  final String categoria;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
    required this.categoria,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'].toString(),
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: json['precio'].toDouble(),
      imagenUrl: json['imagenUrl'],
      categoria: json['categoria'],
    );
  }

  // 🧪 Productos simulados para pruebas en el frontend mientras no hay backend
  static List<Producto> getMockProducts() {
    return [
      Producto(
        id: '1',
        nombre: 'Condimento A',
        descripcion: 'Condimento de alta calidad, ideal para platos salados.',
        precio: 3.99,
        imagenUrl: 'https://via.placeholder.com/150',
        categoria: 'Salados',
      ),
      Producto(
        id: '2',
        nombre: 'Condimento B',
        descripcion: 'Condimento para ensaladas, con un toque de picante.',
        precio: 5.49,
        imagenUrl: 'https://via.placeholder.com/150',
        categoria: 'Picantes',
      ),
      Producto(
        id: '3',
        nombre: 'Condimento C',
        descripcion: 'Condimento con hierbas naturales, perfecto para carnes.',
        precio: 4.75,
        imagenUrl: 'https://via.placeholder.com/150',
        categoria: 'Naturales',
      ),
    ];
  }
}
