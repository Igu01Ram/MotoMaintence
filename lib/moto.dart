class Moto {
  int id;
  int kmAtual;
  int kmManutencao;

  Moto({
    required this.id,
    required this.kmAtual,
    required this.kmManutencao,
  });

  factory Moto.fromMap(Map<String, dynamic> mapa) {
    return Moto(
      id: mapa['id'],
      kmAtual: mapa['km_atual'],
      kmManutencao: mapa['km_manutencao'],
    );
  }
}
