import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'detalle_producto_screen.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';



class ProductCard extends StatelessWidget {
  final Producto producto;

  const ProductCard({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalleProductoScreen(producto: producto),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Imagen ───────────────────────────────────────────────
            Expanded(
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  producto.imagenUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            // ── Nombre, precio y botón ───────────────────────────────
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${producto.precio.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      final cart = Provider.of<CartService>(
                        context,
                        listen: false,
                      );
                      cart.addProduct(producto);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${producto.nombre} agregado al carrito'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 36),
                    ),
                    child: const Text('Agregar al carrito'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
