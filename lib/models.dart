class Product {
  final String id;
  final String name;
  final List<ProductElement> elements;
  final String ordemProducao;
  final int qtdEmbala;
  bool closed;

  Product({
    required this.id,
    required this.name,
    required this.elements,
    required this.ordemProducao,
    required this.qtdEmbala,
    this.closed = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var elementsFromJson = json['Dados'] as List;
    List<ProductElement> elementsList = elementsFromJson
        .map((elementJson) => ProductElement.fromJson(elementJson))
        .toList();

    return Product(
      id: elementsFromJson[0]['Produto PA'],
      name: elementsFromJson[0]['Descricao PA'],
      elements: elementsList,
      ordemProducao: elementsFromJson[0]['Ordem Producao'],
      qtdEmbala: elementsFromJson[0]['Qtd Embala'],
    );
  }
}

class ProductElement {
  final String id;
  final String name;
  final String barcode;
  final double quantity;
  final double totalComponente;
  int qtdLida;
  bool checked;

  ProductElement({
    required this.id,
    required this.name,
    required this.barcode,
    required this.quantity,
    required this.totalComponente,
    this.qtdLida = 0,
    this.checked = false,
  });

  factory ProductElement.fromJson(Map<String, dynamic> json) {
    return ProductElement(
      id: json['Componente'],
      name: json['Descricao Componente'],
      barcode: json['Codigo Barras'],
      quantity: json['qtd Comp'].toDouble(),
      totalComponente: json['Total Componente'].toDouble(),
    );
  }
}
