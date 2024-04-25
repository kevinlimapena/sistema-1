import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ProductRegistrationScreen extends StatefulWidget {
  const ProductRegistrationScreen({Key? key}) : super(key: key);

  @override
  ProductRegistrationScreenState createState() => ProductRegistrationScreenState();
}

class ProductRegistrationScreenState extends State<ProductRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _elementNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  List<ProductElement> elements = [];
  String _scannedBarcode = 'Nenhum código escaneado';
  String? _selectedLine = 'Eletrônicos';
  final List<String> _productLines = ['Eletrônicos', 'Elétricos', 'Outros'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Produto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Produto',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome do produto';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: 'Linha do Produto',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedLine,
                      items: _productLines.map((line) {
                        return DropdownMenuItem(
                          value: line,
                          child: Text(line),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedLine = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione uma linha de produtos';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _elementNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Item',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do item';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a quantidade';
                        }
                        if (int.tryParse(value) == null || int.parse(value) < 1) {
                          return 'Por favor, insira um número válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      int currentValue = int.parse(_quantityController.text);
                      if (currentValue > 1) {
                        setState(() {
                          _quantityController.text = (currentValue - 1).toString();
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      int currentValue = int.parse(_quantityController.text);
                      setState(() {
                        _quantityController.text = (currentValue + 1).toString();
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: scanBarcode,
                    child: const Text('Escanear Código'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text("Barcode: $_scannedBarcode"),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _scannedBarcode != 'Nenhum código escaneado') {
                    setState(() {
                      elements.add(ProductElement(_elementNameController.text, _scannedBarcode, int.parse(_quantityController.text)));
                      _elementNameController.clear();
                      _quantityController.text = '1'; // Reset to default
                      _scannedBarcode = 'Nenhum código escaneado';
                    });
                  }
                },
                child: const Text('Adicionar Item'),
              ),
              const SizedBox(height: 20),
              Text('Itens Adicionados:', style: Theme.of(context).textTheme.titleMedium),
              for (ProductElement element in elements)
                Card(
                  child: ListTile(
                    title: Text(element.name),
                    subtitle: Text('Código: ${element.barcode}, Quantidade: ${element.quantity}'),
                  ),
                ),
              const SizedBox(height: 20),
              if (elements.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Finalizar Cadastro'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> scanBarcode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.BARCODE);
    if (!mounted) return;

    setState(() {
      _scannedBarcode = barcodeScanRes != '-1' ? barcodeScanRes : 'Nenhum código escaneado';
    });
  }
}

class ProductElement {
  final String name;
  final String barcode;
  final int quantity;

  ProductElement(this.name, this.barcode, this.quantity);
}
