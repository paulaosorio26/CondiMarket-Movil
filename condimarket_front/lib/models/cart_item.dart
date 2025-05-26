import 'product_model.dart';

class CartItem {
  final Producto product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  // Precio total del item (precio unitario * cantidad)
  double get totalPrice => product.precio * quantity;

  // Método para crear desde JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Producto.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.product.id == product.id;
  }

  @override
  int get hashCode => product.id.hashCode;
}