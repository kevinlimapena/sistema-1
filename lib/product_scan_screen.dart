import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:sistema/main_screen.dart';

import 'models.dart';

class ProductScanScreen extends StatefulWidget {
  final List<Product> productList; // Lista de produtos

  const ProductScanScreen({Key? key, required this.productList})
      : super(key: key);

  @override
  State<ProductScanScreen> createState() => _ProductScanScreenState();
}

class _ProductScanScreenState extends State<ProductScanScreen> {
  String _scanBarcode = 'Unknown';
  List<bool> _elementMatches;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  int boxesRead = 0;
  int currentIndex = 0;
  bool showCompleteMessage = false;

  _ProductScanScreenState() : _elementMatches = [];

  late Product _productElements = widget.productList.first;

  @override
  void initState() {
    super.initState();
    _elementMatches = List.filled(_productElements.elements.length, false);
  }

  void _nextProduct() {
    if (currentIndex < widget.productList.length - 1) {
      currentIndex++;
      _productElements = widget.productList[currentIndex];
      _elementMatches = List.filled(_productElements.elements.length, false);
      setState(() {
        showCompleteMessage =
            false; // Reinicia a mensagem para o próximo produto
      });
    } else {
      boxesRead--;
      setState(() {
        // ProductManager.products = [];
      });
      // Todos os produtos foram escaneados
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Completo"),
            content: const Text("Todos os produtos foram escaneados."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              )
            ],
          );
        },
      );
    }
  }

  void _goBack() {
    Navigator.pop(context);
  }

  Future<void> scanBarcode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.DEFAULT);
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
      if (_productElements.elements[i].barcode == scannedBarcode &&
          !_elementMatches[i]) {
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
            content: Text(
                "O barcode: ($scannedBarcode) não pertence a nenhum item."),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"))
            ],
          );
        },
      );
    } else if (_elementMatches.every((element) => element)) {
      setState(() {
        showCompleteMessage = true;
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          buttonColor: navyBlue,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: navyBlue,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      InfoContainerWidget.withText(
                        'Caixas Fechadas: $boxesRead',
                      ),
                      InfoContainerWidget.withText(
                          'Produto: ${_productElements.name}'),
                      InfoContainerWidget.withText(
                          'Linha: ${_productElements.line}'),
                      InfoContainerWidget.withText(
                          'Data e Hora: ${intl.DateFormat('dd/MM/yyyy HH:mm').format(_productElements.dateTime)}'),
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
                            child: const Text('Escanear Item',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ),
                          const SizedBox(height: 10),
                          Text('Produto escaneado: $_scanBarcode',
                              style: const TextStyle(fontSize: 16)),
                          if (showCompleteMessage)
                            ElevatedButton(
                              onPressed: () {
                                _nextProduct();
                                boxesRead++;
                                setState(() {
                                  _elementMatches = List.filled(
                                      _productElements.elements.length, false);
                                  showCompleteMessage = false;
                                });
                              },
                              child: const BlinkingText(
                                'Fechar Caixa',
                              ),
                            ),
                          ElevatedButton(
                            onPressed: _goBack,
                            child: const Icon(Icons.arrow_back),
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
                            elements: _productElements.elements,
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
        3: FlexColumnWidth(1), // Espaço para a coluna de checklist
      },
      border: TableBorder.all(),
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Colors.black),
          children: [
            TableCellWidget.withText('Nome'),
            TableCellWidget.withText('Código'),
            TableCellWidget.withText('Quantidade'),
            TableCellWidget.withText('Escaneado'),
          ],
        ),
        ...product.elements.map((element) {
          int index = product.elements.indexOf(element);
          return TableRow(
            children: [
              TableCellWidget.withText(element.name),
              TableCellWidget.withText(element.barcode),
              TableCellWidget.withText(element.quantity.toString()),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF003366).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _elementMatches[index]
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: _elementMatches[index] ? Colors.green : Colors.grey,
                ),
              )
            ],
          );
        }).toList(),
      ],
    );
  }
}

class TableCellWidget extends StatelessWidget {
  final String text;

  const TableCellWidget.withText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: const Color(0xFF003366).withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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

class BlinkingTextState extends State<BlinkingText>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
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
      child: Text(widget.text,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  }
}

class _SquarePainter extends CustomPainter {
  final int numberOfElements;
  final List<bool> elementMatches;
  final List<ProductElement> elements;

  _SquarePainter({
    required this.numberOfElements,
    required this.elementMatches,
    required this.elements,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 2;
    double elementWidth = size.width / numberOfElements;
    const textStyle = TextStyle(color: Colors.white, fontSize: 12);

    for (int i = 0; i < numberOfElements; i++) {
      paint.color = elementMatches[i] ? Colors.green : Colors.red;
      final rect =
          Rect.fromLTWH(i * elementWidth, 0, elementWidth, size.height);
      canvas.drawRect(rect, paint);

      // Criar TextPainter para cada iteração para garantir que textDirection seja definido
      final textPainter = TextPainter(
        text: TextSpan(text: elements[i].name, style: textStyle),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr, // Definido diretamente aqui
        textScaler: TextScaler.noScaling,
      );

      textPainter.layout(
        minWidth: 0,
        maxWidth: elementWidth,
      );

      final offset = Offset(
        rect.left + (elementWidth - textPainter.width) / 2,
        rect.top + (rect.height - textPainter.height) / 2,
      );

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant _SquarePainter oldDelegate) {
    return oldDelegate.elementMatches != elementMatches ||
        oldDelegate.elements != elements;
  }
}
