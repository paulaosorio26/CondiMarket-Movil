// catalogo_screen.dart

import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';  // Asegúrate de tener un servicio que simule los productos
import 'detalle_producto_screen.dart';

class CatalogoScreen extends StatefulWidget {
  @override
  _CatalogoScreenState createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  late Future<List<Producto>> productos;
  String selectedCategory = 'Todos';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    productos = Future.value(Producto.getMockProducts()); // Simulación de productos para pruebas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo de Productos'),
        backgroundColor: Color(0xFFDBE7F3),  // Color de fondo del AppBar
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
            child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: ProductSearchDelegate());
              },
            ),
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFDBE7F3), // Fondo del cuerpo de la pantalla
        child: Column(
          children: [
            // Filtro por categoría
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: selectedCategory,
                items: <String>['Todos', 'Salados', 'Picantes', 'Naturales']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                hint: Text('Filtrar por categoría'),
              ),
            ),

            // Cargar productos filtrados
            Expanded(
              child: FutureBuilder<List<Producto>>(
                future: productos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay productos disponibles'));
                  }

                  // Filtramos productos según la categoría seleccionada
                  List<Producto> productosFiltrados = snapshot.data!
                      .where((producto) =>
                  selectedCategory == 'Todos' ||
                      producto.categoria == selectedCategory)
                      .toList();

                  return GridView.builder(
                    padding: EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: productosFiltrados.length,
                    itemBuilder: (context, index) {
                      return ProductoCard(producto: productosFiltrados[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductoCard extends StatelessWidget {
  final Producto producto;

  const ProductoCard({Key? key, required this.producto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleProductoScreen(producto: producto),
          ),
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(producto.imagenUrl, fit: BoxFit.cover, width: double.infinity),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                producto.nombre,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('\$${producto.precio.toStringAsFixed(2)}'),
            ),
          ],
        ),
      ),
    );
  }
}

// Delegado de búsqueda de productos
class ProductSearchDelegate extends SearchDelegate {
  final List<Producto> productosMock = Producto.getMockProducts();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Producto> resultados = productosMock
        .where((producto) => producto.nombre.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.75,
      ),
      itemCount: resultados.length,
      itemBuilder: (context, index) {
        return ProductoCard(producto: resultados[index]);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Producto> sugerencias = productosMock
        .where((producto) => producto.nombre.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.75,
      ),
      itemCount: sugerencias.length,
      itemBuilder: (context, index) {
        return ProductoCard(producto: sugerencias[index]);
      },
    );
  }
}
