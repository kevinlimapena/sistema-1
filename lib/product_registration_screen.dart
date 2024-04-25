import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ProductRegistrationScreen extends StatefulWidget {
  const ProductRegistrationScreen({Key? key}) : super(key: key);

  @override
  _ProductRegistrationScreenState createState() => _ProductRegistrationScreenState();
}

class _ProductRegistrationScreenState extends State<ProductRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lineController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  List<ProductElement> elements = [];
  String _scannedBarcode = 'Unknown';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Produto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Produto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lineController,
              decoration: const InputDecoration(
                labelText: 'Linha do Produto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            for (ProductElement element in elements)
              ListTile(
                title: Text(element.name),
                subtitle: Text('Código: ${element.barcode}, Quantidade: ${element.quantity}'),
              ),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: scanBarcode,
              child: const Text('Escanear Código do Item'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty && _scannedBarcode.isNotEmpty && _quantityController.text.isNotEmpty) {
                  setState(() {
                    elements.add(ProductElement(_nameController.text, _scannedBarcode, int.parse(_quantityController.text)));
                    _nameController.clear();
                    _quantityController.clear();
                  });
                }
              },
              child: const Text('Adicionar Item'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Finalizar Cadastro'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> scanBarcode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.BARCODE);
    setState(() {
      _scannedBarcode = barcodeScanRes != '-1' ? barcodeScanRes : 'Unknown';
    });
  }
}

class ProductElement {
  String name;
  String barcode;
  int quantity;

  ProductElement(this.name, this.barcode, this.quantity);
}
