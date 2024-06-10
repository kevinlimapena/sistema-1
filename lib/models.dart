class Product {
  final String id;
  final String name;
  final List<ProductElement> elements;
  bool closed;

  Product({
    required this.id,
    required this.name,
    required this.elements,
    this.closed = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var elementsFromJson = json['Dados'] as List;
    List<ProductElement> elementsList = elementsFromJson.map((elementJson) => ProductElement.fromJson(elementJson)).toList();

    return Product(
      id: elementsFromJson[0]['Produto PA'],
      name: elementsFromJson[0]['Descricao PA'],
      elements: elementsList,
    );
  }
}

class ProductElement {
  final String id;
  final String name;
  final String barcode;
  final double quantity;
  bool checked;

  ProductElement({
    required this.id,
    required this.name,
    required this.barcode,
    required this.quantity,
    this.checked = false,
  });

  factory ProductElement.fromJson(Map<String, dynamic> json) {
    return ProductElement(
      id: json['Componente'],
      name: json['Descricao Componente'],
      barcode: json['Codigo Barras'],
      quantity: json['qtd Comp'].toDouble(),
    );
  }
}
