class Product {
  final String name;
  final String line;
  final DateTime dateTime;
  final List<ProductElement> elements;
  bool closed;

  Product({
    required this.name,
    required this.line,
    required this.dateTime,
    required this.elements,
    this.closed = false,
  });
}

class ProductElement {
  final String name;
  final String barcode;
  final int quantity;
  bool checked;

  ProductElement({
    required this.name,
    required this.barcode,
    required this.quantity,
    this.checked = false,
  });
}

