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
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  int boxesRead = 0;
  bool showCompleteMessage = false;

  _MyAppState() : _elementMatches = [];

  final Product _productElements = Product(
    'Caixa',
    'Fios de Cobre',
    DateTime.now(),
    [
      ProductElement('Cobre', '9780201379624', 10),
      ProductElement('Borracha', '858974669514', 8),
      ProductElement('Silicone', '036000291452', 3),
    ],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    });
    _elementMatches = List.filled(_productElements.elements.length, false);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.dispose();
  }

  Future<void> scanBarcode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print("BARCODE: ($barcodeScanRes)");
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
    bool found = false;
    for (int i = 0; i < _productElements.elements.length; i++) {
      if (_productElements.elements[i].barcode == scannedBarcode && !_elementMatches[i]) {
        _elementMatches[i] = true;
        found = true;
      }
    }

    if (!found) {
      if (!navigatorKey.currentState!.mounted) return;
      showDialog(
        context: navigatorKey.currentState!.context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Barcode não encontrado"),
            content: Text("O barcode: ($scannedBarcode) não pertence a nenhum item."),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK")
              )
            ],
          );
        },
      );
    } else if (_elementMatches.every((element) => element)) {
      setState(() {
        showCompleteMessage = true;
        boxesRead++;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    const Color navyBlue = Color(0xFF003366);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Prototype',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: navyBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          buttonColor: navyBlue,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: navyBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
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
                      InfoContainerWidget.withText('Caixas Fechadas: $boxesRead',),
                      InfoContainerWidget.withText('Produto: ${_productElements.name}'),
                      InfoContainerWidget.withText('Linha: ${_productElements.line}'),
                      InfoContainerWidget.withText('Data e Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(_productElements.dateTime)}'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildElementTable(_productElements),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () => scanBarcode(),
                            child: const Text('Escanear Item', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                          const SizedBox(height: 10),
                          Text('Produto escaneado: $_scanBarcode', style: const TextStyle(fontSize: 16)),
                          if (showCompleteMessage)
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _elementMatches = List.filled(_productElements.elements.length, false);
                                    showCompleteMessage = false;
                                  });
                                },
                                child: const  BlinkingText('Fechar Caixa', ),
                            ),

                        ],
                      ),
                      const SizedBox(width: 20),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.17,
                        height: MediaQuery.of(context).size.width * 0.17,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: CustomPaint(
                          painter: _SquarePainter(
                            numberOfElements: _productElements.elements.length,
                            elementMatches: _elementMatches,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                  const SizedBox(height: 20),
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
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color(0xFF003366).withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
        color: const Color(0xFF003366),
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

class BlinkingText extends StatefulWidget {
  final String text;

  const BlinkingText(this.text, {Key? key}) : super(key: key);

  @override
  BlinkingTextState createState() => BlinkingTextState();
}

class BlinkingTextState extends State<BlinkingText> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller!,
      child: Text(widget.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
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
