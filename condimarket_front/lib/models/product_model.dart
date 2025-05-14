// models/product_model.dart
class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl;
  final String categoria;
  final int stock;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
    required this.categoria,
    this.stock = 0,
  });

  // Método de fábrica para convertir JSON a objeto Producto
  factory Producto.fromJson(Map<String, dynamic> json) {
    // Manejo de posibles valores nulos o tipos incorrectos
    return Producto(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? 'Sin nombre',
      descripcion: json['descripcion'] ?? 'Sin descripción',
      precio: _parseDouble(json['precio']),
      imagenUrl: json['imagenUrl'] ?? 'https://via.placeholder.com/150',
      categoria: json['categoria'] ?? 'Otros',
      stock: json['stock'] != null ? int.tryParse(json['stock'].toString()) ?? 0 : 0,
    );
  }

  // Helper para convertir a double con seguridad
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Método para convertir objeto Producto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagenUrl': imagenUrl,
      'categoria': categoria,
      'stock': stock,
    };
  }

  // Productos simulados para pruebas en el frontend mientras no hay backend
  static List<Producto> getMockProducts() {
    return [
      Producto(
        id: '1',
        nombre: 'Canela Astilla',
        descripcion: 'Canela en astilla de alta calidad. Ideal para postres y bebidas calientes.',
        precio: 49.0,
        imagenUrl: 'https://via.placeholder.com/150?text=Canela',
        categoria: 'Naturales',
        stock: 10,
      ),
      Producto(
        id: '2',
        nombre: 'Ajo Molido',
        descripcion: 'Ajo molido de alta calidad. Perfecto para condimentar carnes y salsas.',
        precio: 35.0,
        imagenUrl: 'https://via.placeholder.com/150?text=Ajo',
        categoria: 'Procesados',
        stock: 20,
      ),
      Producto(
        id: '3',
        nombre: 'Pimienta Negra',
        descripcion: 'Pimienta negra molida. Excelente para dar sabor a tus platillos.',
        precio: 42.0,
        imagenUrl: 'https://via.placeholder.com/150?text=Pimienta',
        categoria: 'Naturales',
        stock: 15,
      ),
      Producto(
        id: '4',
        nombre: 'Azúcar Vainillada',
        descripcion: 'Azúcar con aroma de vainilla. Perfecta para repostería.',
        precio: 38.0,
        imagenUrl: 'https://via.placeholder.com/150?text=Azucar',
        categoria: 'Dulces',
        stock: 25,
      ),
    ];
  }
}