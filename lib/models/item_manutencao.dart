class ItemManutencao {
  int id;
  String nome;
  int kmRevisao;

  ItemManutencao({
    required this.id,
    required this.nome,
    this.kmRevisao = 0,
  });

  factory ItemManutencao.fromMap(Map<String, dynamic> mapa) {
    return ItemManutencao(
      id: mapa['id'],
      nome: mapa['nome'],
      kmRevisao: mapa['km_revisao'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {'id': id, 'nome': nome, 'km_revisao': kmRevisao};
}
