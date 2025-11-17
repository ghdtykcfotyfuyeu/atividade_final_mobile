class Veiculo {
  String? id;
  String modelo;
  String marca;
  String placa;
  int ano;
  String tipoCombustivel;

  Veiculo({
    this.id,
    required this.modelo,
    required this.marca,
    required this.placa,
    required this.ano,
    required this.tipoCombustivel,
  });

  Map<String, dynamic> toMap() {
    return {
      "modelo": modelo,
      "marca": marca,
      "placa": placa,
      "ano": ano,
      "tipoCombustivel": tipoCombustivel,
    };
  }

  factory Veiculo.fromMap(String id, Map<String, dynamic> map) {
    return Veiculo(
      id: id,
      modelo: map['modelo'],
      marca: map['marca'],
      placa: map['placa'],
      ano: map['ano'],
      tipoCombustivel: map['tipoCombustivel'],
    );
  }
}
