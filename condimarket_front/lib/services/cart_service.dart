import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/cart_item.dart';

class CartService with ChangeNotifier {
  List<CartItem> _items = [];
  static const double _deliveryFee = 3000.0; // Precio de domicilio fijo

  // Getter para obtener los items del carrito
  List<CartItem> get items => List.unmodifiable(_items);

  // Getter para obtener la cantidad total de items
  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);

  // Getter para obtener el subtotal (sin domicilio)
  double get subtotal => _items.fold(0, (total, item) => total + item.totalPrice);

  // Getter para obtener el precio de domicilio
  double get deliveryFee => _deliveryFee;

  // Getter para obtener el total (subtotal + domicilio)
  double get total => subtotal + _deliveryFee;

  // Verificar si el carrito está vacío
  bool get isEmpty => _items.isEmpty;

  // Agregar producto al carrito
  void addProduct(Producto product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Si el producto ya existe, aumentar la cantidad
      _items[existingIndex].quantity += quantity;
    } else {
      // Si no existe, crear nuevo CartItem
      _items.add(CartItem(product: product, quantity: quantity));
    }

    notifyListeners();
  }

  // Remover producto del carrito completamente
  void removeProduct(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // Incrementar cantidad de un producto
  void incrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  // Decrementar cantidad de un producto
  void decrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        // Si la cantidad es 1, remover el producto del carrito
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Actualizar cantidad específica de un producto
  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeProduct(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  // Limpiar carrito
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Obtener cantidad de un producto específico en el carrito
  int getProductQuantity(String productId) {
    final item = _items.firstWhere(
          (item) => item.product.id == productId,
      orElse: () => CartItem(product: Producto(id: '', nombre: '', descripcion: '', precio: 0, imagenUrl: '', categoria: ''), quantity: 0),
    );
    return item.quantity;
  }

  // Verificar si un producto está en el carrito
  bool containsProduct(String productId) {
    return _items.any((item) => item.product.id == productId);
  }
}