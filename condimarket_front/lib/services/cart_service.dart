import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/cart_item.dart';
import '../services/cart_http_service.dart';

class CartService with ChangeNotifier {
  List<CartItem> _items = [];
  static const double _deliveryFee = 3000.0;
  bool _isLoading = false;
  bool _isInitialized = false;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);
  double get subtotal => _items.fold(0, (total, item) => total + item.totalPrice);
  double get deliveryFee => _deliveryFee;
  double get total => subtotal + _deliveryFee;
  bool get isEmpty => _items.isEmpty;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Inicializar carrito
  Future<void> initializeCart() async {
    if (!_isInitialized) {
      await loadCart();
      _isInitialized = true;
    }
  }

  // Cargar carrito desde el backend
  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final cartData = await CartHttpService.getCartItems();
      print('Cart data received: $cartData');

      _items = cartData.map((item) {
        final product = Producto(
          id: int.parse(item['productId'].toString()),
          nombre: item['productName'] ?? '',
          descripcion: item['description'] ?? '',
          precio: (item['price'] ?? 0.0).toDouble(),
          imagenUrl: item['imageUrl'] ?? 'assets/placeholder.png',
          categoria: item['category'] ?? '',
        );

        return CartItem(
          product: product,
          quantity: item['quantity'] ?? 1,
        );
      }).toList();

      print('Items loaded: ${_items.length}');
      // Debug: verificar que los datos estén completos
      for (var item in _items) {
        print('Product: ${item.product.nombre}, Quantity: ${item.quantity}, Image: ${item.product.imagenUrl}');
      }
    } catch (e) {
      print('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ MÉTODO PRINCIPAL CORREGIDO - Agregar producto al carrito
  Future<void> addProduct(Producto product, {int quantity = 1}) async {
    if (quantity <= 0) return;

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Actualizar localmente para UX inmediata
      final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
      CartItem? backupItem;

      if (existingIndex >= 0) {
        // Guardar estado previo para posible rollback
        backupItem = CartItem(
          product: _items[existingIndex].product,
          quantity: _items[existingIndex].quantity,
        );
        _items[existingIndex].quantity += quantity;
      } else {
        _items.add(CartItem(product: product, quantity: quantity));
      }

      notifyListeners(); // Mostrar cambio inmediato

      // 2. Sincronizar con backend
      final success = await CartHttpService.addToCart(product, quantity);

      if (!success) {
        print('Failed to sync with backend, reverting changes...');
        // Revertir cambios locales
        if (existingIndex >= 0 && backupItem != null) {
          _items[existingIndex].quantity = backupItem.quantity;
        } else {
          _items.removeWhere((item) => item.product.id == product.id);
        }
        throw Exception('Failed to add product to cart');
      }

      // 3. ✅ NO recargar automáticamente - mantener datos locales
      // Solo recargar si hay discrepancias críticas
      print('Product added successfully, keeping local state');

    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Método para sincronizar solo cuando sea necesario
  Future<void> syncWithBackend() async {
    if (_isLoading) return;

    print('Syncing with backend...');
    await loadCart();
  }

  // Eliminar producto completamente del carrito
  Future<void> removeProduct(int productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('Removing product with ID: $productId');

      // Guardar item para posible rollback
      final itemToRemove = _items.firstWhere(
            (item) => item.product.id == productId,
        orElse: () => CartItem(
          product: Producto(id: 0, nombre: '', descripcion: '', precio: 0, imagenUrl: '', categoria: ''),
          quantity: 0,
        ),
      );

      // Eliminar localmente primero
      _items.removeWhere((item) => item.product.id == productId);
      notifyListeners();

      // Sincronizar con backend
      final success = await CartHttpService.removeFromCart(productId.toString());

      if (!success) {
        // Revertir si falla
        if (itemToRemove.product.id != 0) {
          _items.add(itemToRemove);
        }
        print('Failed to remove product from cart');
      } else {
        print('Product removed successfully');
      }
    } catch (e) {
      print('Error removing product: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Incrementar cantidad
  Future<void> incrementQuantity(int productId) async {
    final item = _items.firstWhere(
          (item) => item.product.id == productId,
      orElse: () => throw Exception('Product not found in cart'),
    );

    print('Incrementing quantity for product: ${item.product.nombre}');
    await addProduct(item.product, quantity: 1);
  }

  // ✅ Decrementar cantidad mejorado
  Future<void> decrementQuantity(int productId) async {
    final itemIndex = _items.indexWhere((item) => item.product.id == productId);
    if (itemIndex == -1) {
      print('Product not found in cart');
      return;
    }

    final currentItem = _items[itemIndex];
    print('Decrementing quantity for product: ${currentItem.product.nombre}, current: ${currentItem.quantity}');

    if (currentItem.quantity > 1) {
      // Actualizar localmente
      final previousQuantity = currentItem.quantity;
      currentItem.quantity -= 1;
      notifyListeners();

      // Sincronizar con backend
      _isLoading = true;
      notifyListeners();

      try {
        // Usar el método de actualización más eficiente
        final success = await CartHttpService.updateQuantity(productId.toString(), currentItem.quantity);

        if (!success) {
          // Revertir si falla
          currentItem.quantity = previousQuantity;
          print('Failed to update quantity, reverted changes');
        }
      } catch (e) {
        currentItem.quantity = previousQuantity;
        print('Error decrementing quantity: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      // Si solo hay 1, eliminar completamente
      await removeProduct(productId);
    }
  }

  // Actualizar cantidad específica
  Future<void> updateQuantity(int productId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeProduct(productId);
      return;
    }

    final itemIndex = _items.indexWhere((item) => item.product.id == productId);
    if (itemIndex == -1) {
      print('Product not found in cart');
      return;
    }

    final currentItem = _items[itemIndex];
    final previousQuantity = currentItem.quantity;

    print('Updating quantity for product: ${currentItem.product.nombre} to: $newQuantity');

    // Actualizar localmente primero
    currentItem.quantity = newQuantity;
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      final success = await CartHttpService.updateQuantity(productId.toString(), newQuantity);

      if (!success) {
        // Revertir si falla
        currentItem.quantity = previousQuantity;
        print('Failed to update quantity, reverted changes');
      }
    } catch (e) {
      currentItem.quantity = previousQuantity;
      print('Error updating quantity: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpiar carrito
  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('Clearing cart...');

      // Guardar items para posible rollback
      final backupItems = List<CartItem>.from(_items);

      // Limpiar localmente
      _items.clear();
      notifyListeners();

      // Sincronizar con backend
      final success = await CartHttpService.clearCart();

      if (!success) {
        // Revertir si falla
        _items.addAll(backupItems);
        print('Failed to clear cart, reverted changes');
      } else {
        print('Cart cleared successfully');
      }
    } catch (e) {
      print('Error clearing cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para limpiar sesión (logout)
  void clearSession() {
    _items.clear();
    _isInitialized = false;
    CartHttpService.clearSession();
    notifyListeners();
  }

  int getProductQuantity(int productId) {
    final item = _items.firstWhere(
          (item) => item.product.id == productId,
      orElse: () => CartItem(
        product: Producto(id: 0, nombre: '', descripcion: '', precio: 0, imagenUrl: '', categoria: ''),
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  bool containsProduct(int productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // Agrega producto directamente en memoria sin hacer petición HTTP
  void addItem(Producto product, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }

    notifyListeners();
  }
}