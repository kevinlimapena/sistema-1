import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';

import 'product_scan_screen.dart';
import 'models.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        reload();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void reload() => setState(() {});

  void delete() => setState(() {
        ProductManager.products = [];
      });

  Future<void> scanBarcode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.DEFAULT);
      _fetchProductData(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _fetchProductData(String productCode) async {
    //String url = 'http://yamadalomfabricacao123875.protheus.cloudtotvs.com.br:4050/rest/IPENA/IP_ESTRUTURA?CodPA=$productCode';
    String url =
        'http://yamadalomfabricacao123875.protheus.cloudtotvs.com.br:4050/rest/IPENA/IP_ESTRUTURA?NUMOP=$productCode';
    String username = 'IPENA';
    String password = 'Nina@2010';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    print('Requesting product data for code: $productCode');
    print('URL: $url');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': basicAuth},
      );

      Navigator.of(context).pop();

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          ProductManager.products.add(Product.fromJson(data));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductScanScreen(productList: ProductManager.products),
            ),
          );
        });
      } else {
        _showErrorDialog('A requisição falhou \n\n${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('O código que você digitou não existe \n\n$e');
      print('Error: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showCodeInputDialog() {
    TextEditingController _codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Transform.translate(
          offset: Offset(-90, 0),
          child: AlertDialog(
            title: const Text('Digite o código do PA'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Código PA',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('Entrar'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  print('Submitting code: ${_codeController.text}');
                  await _fetchProductData(_codeController.text);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esteira de Produtos'),
        actions: [IconButton(onPressed: delete, icon: Icon(Icons.delete))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                if (ProductManager.products.isEmpty) {
                  _showCodeInputDialog();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductScanScreen(
                          productList: ProductManager.products),
                    ),
                  );
                }
              },
              child: const Text('Digite Produto'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 35),
                textStyle: TextStyle(fontSize: 20),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (ProductManager.products.isEmpty) {
                  scanBarcode();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductScanScreen(
                          productList: ProductManager.products),
                    ),
                  );
                }
              },
              child: const Text('Escanear Produto'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 35),
                textStyle: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductManager {
  static List<Product> products = [];
}
