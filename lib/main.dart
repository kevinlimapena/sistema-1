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
  List<bool> _elementMatches = [];

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
    _elementMatches = List.generate(
      _productElements.elements.length,
          (index) => _productElements.elements[index].barcode == scannedBarcode,
    );
  }

  final Product _productElements = Product(
    'Caixa',
    'Fios de Cobre',
    DateTime.now(),
    [
      ProductElement('Cobre', '9780201379624', 10),
      ProductElement('Borracha', '012345678901', 8),
      ProductElement('Aço', '012345678901', 2),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Prototype',
      theme: ThemeData(
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
                        double halfScreenWidth =
                            MediaQuery.of(context).size.width / 6;
                        return Container(
                          width: halfScreenWidth,
                          height: halfScreenWidth,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
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
                  Text(
                    'Scan result : $_scanBarcode\n',
                    style: const TextStyle(fontSize: 20),
                  )
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
          decoration: BoxDecoration(color: Colors.grey),
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
        color: Colors.grey[300],
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
      if (elementMatches.isNotEmpty && elementMatches[i]) {
        paint.color = Colors.green;
      } else {
        paint.color = Colors.red;
      }
      double startX = i * elementWidth;
      double startY = 0;
      double endX = (i + 1) * elementWidth;
      double endY = size.height;
      canvas.drawRect(Rect.fromLTRB(startX, startY, endX, endY), paint);
      paint.color = Colors.black;
      canvas.drawLine(Offset(startX, startY), Offset(startX, endY), paint);
      canvas.drawLine(Offset(endX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(_SquarePainter oldDelegate) =>
      oldDelegate.elementMatches != elementMatches;
}
