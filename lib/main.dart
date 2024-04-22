import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  Future<String> scanBarcode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', // Cor do botão de cancelamento
      'Cancelar', // Texto do botão de cancelamento
      true, // Mostrar flash
      ScanMode.BARCODE, // Modo de digitalização
    );

    return barcodeScanRes;
  }

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InfoContainerWidget.withText('Produto: 001'),
                    InfoContainerWidget.withText('Linha: Fios de Cobre'),
                    InfoContainerWidget.withText(
                        'Data e Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}'),
                  ],
                ),
                const SizedBox(height: 20),
                _buildAttributeTable(),
                const SizedBox(height: 10),
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
                  onPressed: () async {
                    String barcodeScanRes = await scanBarcode();
                    // Faça algo com o código de barras escaneado
                    print('Código de barras escaneado: $barcodeScanRes');
                  },
                  child: Text('Escanear Código de Barras'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttributeTable() {
    return Row(
      children: [
        Expanded(
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
            },
            border: TableBorder.all(),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Colors.black),
                children: [
                  TableCellWidget.withText('Estrutura'),
                  TableCellWidget.withText('Quantidade'),
                ],
              ),
              TableRow(
                children: [
                  TableCellWidget.withText('Cobre'),
                  TableCellWidget.withText('10'),
                ],
              ),
              TableRow(
                children: [
                  TableCellWidget.withText('Borracha'),
                  TableCellWidget.withText('8'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}

class TableCellWidget extends StatelessWidget {
  final String text;

  TableCellWidget.withText(this.text);

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(text),
      ),
    );
  }
}

class InfoContainerWidget extends StatelessWidget {
  final String text;

  InfoContainerWidget.withText(this.text);

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
