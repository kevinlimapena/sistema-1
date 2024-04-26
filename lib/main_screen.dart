import 'package:flutter/material.dart';
import 'product_registration_screen.dart';
import 'product_scan_screen.dart';
import 'models.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esteira de Produtos'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ProductRegistrationScreen()),
            ),
            child: const Text('Cadastro de Produto'),
          ),
          ElevatedButton(
            onPressed: () {
              if (ProductManager.products.isEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Aviso'),
                      content: Text('Nenhum produto disponível para escanear.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop(); // Fecha o dialog
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductScanScreen(productList: ProductManager.products),
                  ),
                );
              }
            },
            child: const Text('Escanear Produto'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: ProductManager.products.length,
              itemBuilder: (context, index) {
                final product = ProductManager.products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                      'Linha: ${product.line}, Data: ${product.dateTime.toString()}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductManager {
  static List<Product> products = [];
}
