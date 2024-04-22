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

  Future<void> scanBarcode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Product caixaProduto = Product(
      'Caixa de Produtos',
      'Fios de Cobre',
      DateTime.now(),
      [
        ProductElement('Cobre', '011274755558', 10),
        ProductElement('Borracha', '012345678901', 8),
      ],
    );

    return MaterialApp(
      title: 'Protótipo Flutter',
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
                          'Produto: ${caixaProduto.nome}'),
                      InfoContainerWidget.withText(
                          'Linha: ${caixaProduto.linha}'),
                      InfoContainerWidget.withText(
                          'Data e Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(caixaProduto.dataHora)}'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildElementTable(caixaProduto),
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
                            color: Colors.red, // Fundo vermelho
                            border: Border.all(),
                          ),
                          child: CustomPaint(
                            painter: _VerticalLinesPainter(
                                2), // Ajuste o número de elementos conforme necessário
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () => scanBarcode(),
                      child: const Text('Start barcode scan')),
                  Text('Scan result : $_scanBarcode\n',
                      style: const TextStyle(fontSize: 20))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElementTable(Product produto) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1),
      },
      border: TableBorder.all(),
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Colors.grey),
          children: [
            TableCellWidget.withText('Nome'),
            TableCellWidget.withText('Código de Barras'),
            TableCellWidget.withText('Quantidade'),
          ],
        ),
        for (final element in produto.elementos)
          TableRow(
            children: [
              TableCellWidget.withText(element.elementName),
              TableCellWidget.withText(element.codigoBarras),
              TableCellWidget.withText(element.quantidade.toString()),
            ],
          ),
      ],
    );
  }
}

class Product {
  final String nome;
  final String linha;
  final DateTime dataHora;
  final List<ProductElement> elementos;

  Product(this.nome, this.linha, this.dataHora, this.elementos);
}

class ProductElement {
  final String elementName;
  final String codigoBarras;
  final int quantidade;

  ProductElement(this.elementName, this.codigoBarras, this.quantidade);
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

class _VerticalLinesPainter extends CustomPainter {
  final int numberOfElements;

  _VerticalLinesPainter(this.numberOfElements);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    for (int i = 1; i < numberOfElements; i++) {
      double x = i * size.width / numberOfElements;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_VerticalLinesPainter oldDelegate) =>
      oldDelegate.numberOfElements != numberOfElements;
}
