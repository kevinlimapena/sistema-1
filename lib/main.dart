import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _scanBarcode = 'Unknown';
  List<bool> _elementMatches;

  _MyAppState() : _elementMatches = [];

  @override
  void initState() {
    super.initState();
    _elementMatches = List.filled(_productElements.elements.length, false);
  }

  Future<void> scanBarcode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
      _checkBarcodeMatch(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  void _checkBarcodeMatch(String scannedBarcode) {
    for (int i = 0; i < _productElements.elements.length; i++) {
      if (_productElements.elements[i].barcode == scannedBarcode) {
        _elementMatches[i] = true;
      }
    }
    setState(() {});
  }

  final Product _productElements = Product(
    'Caixa',
    'Fios de Cobre',
    DateTime.now(),
    [
      ProductElement('Cobre', '9780201379624', 10),
      ProductElement('Borracha', '858974669514', 8),
      ProductElement('Borracha', '036000291452', 3),
    ],
  );

  @override
  Widget build(BuildContext context) {
    bool allItemsScanned = !_elementMatches.contains(false);

    return MaterialApp(
      title: 'Flutter Prototype',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InfoContainerWidget.withText(
                          'Produto: ${_productElements.name}'),
                      InfoContainerWidget.withText(
                          'Linha: ${_productElements.line}'),
                      InfoContainerWidget.withText(
                          'Data e Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(_productElements.dateTime)}'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildElementTable(_productElements),
                  const SizedBox(height: 20),
                  Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          width: constraints.maxWidth / 2,
                          height: constraints.maxWidth / 2,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent),
                          ),
                          child: CustomPaint(
                            painter: _SquarePainter(
                              numberOfElements: _productElements.elements.length,
                              elementMatches: _elementMatches,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => scanBarcode(),
                    child: const Text('Start barcode scan'),
                  ),
                  Text('Scan result: $_scanBarcode', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: allItemsScanned ? () => print("Load next product") : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: allItemsScanned ? Colors.green : Colors.grey, disabledForegroundColor: Colors.grey.withOpacity(0.38), disabledBackgroundColor: Colors.grey.withOpacity(0.12), // Color for disabled state
                    ),
                    child: const Text('Load Next Product'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElementTable(Product product) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      border: TableBorder.all(),
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Colors.black),
          children: [
            TableCellWidget.withText('Nome'),
            TableCellWidget.withText('Código'),
            TableCellWidget.withText('Quantidade'),
          ],
        ),
        for (final element in product.elements)
          TableRow(
            children: [
              TableCellWidget.withText(element.name),
              TableCellWidget.withText(element.barcode),
              TableCellWidget.withText(element.quantity.toString()),
            ],
          ),
      ],
    );
  }
}

class Product {
  final String name;
  final String line;
  final DateTime dateTime;
  final List<ProductElement> elements;

  Product(this.name, this.line, this.dateTime, this.elements);
}

class ProductElement {
  final String name;
  final String barcode;
  final int quantity;

  ProductElement(this.name, this.barcode, this.quantity);
}

class TableCellWidget extends StatelessWidget {
  final String text;

  const TableCellWidget.withText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text),
      ),
    );
  }
}

class InfoContainerWidget extends StatelessWidget {
  final String text;

  const InfoContainerWidget.withText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SquarePainter extends CustomPainter {
  final int numberOfElements;
  final List<bool> elementMatches;

  _SquarePainter({required this.numberOfElements, required this.elementMatches});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 2;
    double elementWidth = size.width / numberOfElements;
    for (int i = 0; i < numberOfElements; i++) {
      paint.color = elementMatches[i] ? Colors.green : Colors.red;
      canvas.drawRect(Rect.fromLTWH(i * elementWidth, 0, elementWidth, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_SquarePainter oldDelegate) => oldDelegate.elementMatches != elementMatches;
}
