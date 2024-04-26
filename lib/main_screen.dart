import 'package:flutter/material.dart';
import 'product_registration_screen.dart';
import 'product_scan_screen.dart';
import 'models.dart';

import 'dart:async';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      reload();
    });
  }

  void reload() => setState(() {});

  void delete() => setState(() {
        ProductManager.products = [];
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esteira de Produtos'),
        actions: [
          Spacer(),
          IconButton(onPressed: reload, icon: Icon(Icons.refresh)),
          IconButton(onPressed: delete, icon: Icon(Icons.delete))
        ],
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
                      title: const Text('Aviso'),
                      content: const Text(
                          'Nenhum produto disponível para escanear.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
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
          Text("Produtos cadastrados:"),
          Expanded(
            child: ListView.builder(
              itemCount: ProductManager.products.length,
              itemBuilder: (context, index) {
                final product = ProductManager.products[index];
                return Card(
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                        'Linha: ${product.line}, Data: ${product.dateTime.toString()}'),
                  ),
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
