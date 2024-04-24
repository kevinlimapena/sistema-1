import 'package:flutter/material.dart';
import 'product_registration_screen.dart';
import 'product_scan_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductRegistrationScreen()),
              ),
              child: const Text('Cadastro de Produto'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductScanScreen()),
              ),
              child: const Text('Escanear Produto'),
            ),
          ],
        ),
      ),
    );
  }
}
