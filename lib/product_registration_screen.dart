import 'package:flutter/material.dart';

class ProductRegistrationScreen extends StatelessWidget {
  const ProductRegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Produto'),
      ),
      body: const Center(
        child: Text('Formulário de Cadastro de Produto'),
      ),
    );
  }
}
