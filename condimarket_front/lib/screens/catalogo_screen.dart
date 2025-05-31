import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';

import '../screens/product_card.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  _CatalogoScreenState createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  late Future<List<Producto>> productos;
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  String selectedCategory = 'Todos';
  String searchQuery = '';
  List<String> categorias = ['Todos', 'Naturales', 'Procesados', 'Dulces', 'Otros'];
  List<String> _sugerencias = [];

  @override
  void initState() {
    super.initState();
    _cargarProductosFiltrados();
  }

  String _norm(String s) {
    final t = s.trim().toLowerCase();
    const ac = 'áéíóúüñ';
    const an = 'aeiouun';
    var out = t;
    for (var i = 0; i < ac.length; i++) {
      out = out.replaceAll(ac[i], an[i]);
    }
    return out;
  }

  void _cargarProductosFiltrados() {
    setState(() {
      productos = _productService.fetchProducts().then((lista) {
        return lista.where((producto) {
          final catProd = _norm(producto.categoria);
          final catSel = _norm(selectedCategory);
          final coincideCategoria = selectedCategory == 'Todos' || catProd == catSel;
          final coincideBusqueda = _norm(producto.nombre).contains(_norm(searchQuery));
          return coincideCategoria && coincideBusqueda;
        }).toList();
      }).catchError((error) {
        final mockList = Producto.getMockProducts();
        return mockList.where((producto) {
          final catProd = _norm(producto.categoria);
          final catSel = _norm(selectedCategory);
          final coincideCategoria = selectedCategory == 'Todos' || catProd == catSel;
          final coincideBusqueda = _norm(producto.nombre).contains(_norm(searchQuery));
          return coincideCategoria && coincideBusqueda;
        }).toList();
      });
    });
  }

  void _onSearchSubmitted(String value) {
    setState(() {
      searchQuery = value;
      _sugerencias.clear(); // Oculta sugerencias al enviar
      _cargarProductosFiltrados();
    });
  }

  void _actualizarSugerencias(String value) async {
    final productosLista = await _productService.fetchProducts();
    setState(() {
      _sugerencias = productosLista
          .map((p) => p.nombre)
          .where((nombre) => _norm(nombre).contains(_norm(value)))
          .toSet()
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('CondiMarket', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<CartService>(
            builder: (context, cartService, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.black),
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                  ),
                  if (cartService.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          '${cartService.itemCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFFEAEFF5),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        searchQuery = '';
                        _sugerencias.clear();
                        _cargarProductosFiltrados(); // 🔥 recargar productos sin filtro
                      });
                    } else {
                      _actualizarSugerencias(value);
                      setState(() {
                        searchQuery = _norm(value);
                      });
                    }
                  },
                  onSubmitted: _onSearchSubmitted,
                ),
                if (_sugerencias.isNotEmpty)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _sugerencias.length,
                      itemBuilder: (context, index) {
                        final s = _sugerencias[index];
                        return ListTile(
                          title: Text(s),
                          onTap: () {
                            _searchController.text = s;
                            _onSearchSubmitted(s);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Categorías', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
                SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categorias.map((categoria) {
                      Color color;
                      IconData iconData = Icons.spa;

                      switch (categorias.indexOf(categoria)) {
                        case 1:
                          color = Color(0xFF65D196);
                          iconData = Icons.spa;
                          break;
                        case 2:
                          color = Color(0xFFFFA726);
                          iconData = Icons.kitchen;
                          break;
                        case 3:
                          color = Color(0xFFE57373);
                          iconData = Icons.cake;
                          break;
                        case 4:
                          color = Color(0xFF64B5F6);
                          iconData = Icons.category;
                          break;
                        default:
                          color = Colors.grey;
                          break;
                      }

                      if (categoria == 'Todos') return SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = categoria;
                              _cargarProductosFiltrados();
                            });
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(iconData, color: Colors.white, size: 24),
                                SizedBox(height: 4),
                                Text(
                                  categoria,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Productos populares', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<Producto>>(
                      future: productos,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error al cargar productos'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text('No hay productos disponibles'));
                        }

                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return ProductCard(producto: snapshot.data![index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: Icon(Icons.home, color: Colors.grey), onPressed: () {}),
            IconButton(icon: Icon(Icons.grid_view, color: Colors.grey), onPressed: () {}),
            FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/cart'),
              backgroundColor: Colors.orange,
              elevation: 2,
              child: Icon(Icons.shopping_cart),
            ),
            IconButton(icon: Icon(Icons.favorite_border, color: Colors.grey), onPressed: () {}),
            IconButton(icon: Icon(Icons.person_outline, color: Colors.grey), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
