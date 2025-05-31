class Producto {
  final int id;
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

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id         : int.tryParse(json['id'].toString()) ?? 0,
      nombre     : json['nameProduct']        ?? 'Sin nombre',
      descripcion: json['description']        ?? 'Sin descripción',
      precio     : _parseDouble(json['amountProduct']),
      imagenUrl  : json['image']              ?? 'https://via.placeholder.com/150',
      categoria  : json['categoryName']
          ?? json['category']
          ?? 'Sin categoría',
      stock      : json['stock'] != null
          ? int.tryParse(json['stock'].toString()) ?? 0
          : 0,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int)    return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() => {
    'id'           : id,
    'nameProduct'  : nombre,
    'description'  : descripcion,
    'amountProduct': precio,
    'image'        : imagenUrl,
    'categoryName' : categoria,
    'stock'        : stock,
  };

  static List<Producto> getMockProducts() => [
    Producto(
      id: 1,
      nombre: 'Canela Astilla',
      descripcion: 'Canela en astilla de alta calidad. Ideal para postres y bebidas calientes.',
      precio: 49.0,
      imagenUrl: 'images/CanelaAstilla10.png',
      categoria: 'Dulces',
      stock: 10,
    ),
    Producto(
      id: 2,
      nombre: 'Ajo Molido',
      descripcion: 'Ajo molido de alta calidad. Perfecto para condimentar carnes y salsas.',
      precio: 35.0,
      imagenUrl: 'images/AjoMolido30.png',
      categoria: 'Procesados',
      stock: 20,
    ),
    Producto(
      id: 3,
      nombre: 'Pimienta Pepa',
      descripcion: 'Pimienta Pepa. Excelente para dar sabor a tus platillos.',
      precio: 42.0,
      imagenUrl: 'images/PimientaPepa10.png',
      categoria: 'Naturales',
      stock: 15,
    ),
    Producto(
      id: 4,
      nombre: 'Vinagre de Manzana',
      descripcion: 'Vinagre de manzana de 500 ml, ideal para aderezos y marinadas.',
      precio: 38.0,
      imagenUrl: 'images/VinagreManzana500.jpg',
      categoria: 'Otros',
      stock: 25,
    ),
  ];
}
