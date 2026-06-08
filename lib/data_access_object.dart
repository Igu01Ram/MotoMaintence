import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'moto.dart';
import 'item_manutencao.dart';

class DataAccessObject {
  // ===== MOTO =====

  static Future<Moto> obterMoto() async {
    final prefs = await SharedPreferences.getInstance();
    return Moto(
      id: 1,
      kmAtual: prefs.getInt('moto_km_atual') ?? 0,
      kmManutencao: prefs.getInt('moto_km_manutencao') ?? 1000,
    );
  }

  static Future<void> atualizarMoto(int kmAtual, int kmManutencao) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('moto_km_atual', kmAtual);
    await prefs.setInt('moto_km_manutencao', kmManutencao);
  }

  static Future<void> incrementarKm(int incremento) async {
    final moto = await obterMoto();
    await atualizarMoto(moto.kmAtual + incremento, moto.kmManutencao);
  }

  // ===== ITENS DE MANUTENÇÃO =====

  static Future<List<ItemManutencao>> obterItens() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('items');
    if (jsonStr == null) {
      final defaults = [
        ItemManutencao(id: 1, nome: 'Óleo'),
        ItemManutencao(id: 2, nome: 'Pneu'),
        ItemManutencao(id: 3, nome: 'Filtro de Óleo'),
        ItemManutencao(id: 4, nome: 'Pastilha de Freio'),
        ItemManutencao(id: 5, nome: 'Corrente'),
        ItemManutencao(id: 6, nome: 'Vela'),
      ];
      await _salvarItens(defaults);
      return defaults;
    }
    final List<dynamic> list = json.decode(jsonStr);
    return list
        .map((m) => ItemManutencao.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  static Future<void> _salvarItens(List<ItemManutencao> itens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'items', json.encode(itens.map((i) => i.toMap()).toList()));
  }

  static Future<void> incluirItem(String nome, {int kmRevisao = 0}) async {
    final itens = await obterItens();
    final newId = itens.isEmpty
        ? 1
        : itens.map((i) => i.id).reduce((a, b) => a > b ? a : b) + 1;
    itens.add(ItemManutencao(id: newId, nome: nome, kmRevisao: kmRevisao));
    await _salvarItens(itens);
  }

  static Future<void> atualizarItem(int id, String nome, {int kmRevisao = 0}) async {
    final itens = await obterItens();
    final index = itens.indexWhere((i) => i.id == id);
    if (index != -1) {
      itens[index] = ItemManutencao(id: id, nome: nome, kmRevisao: kmRevisao);
      await _salvarItens(itens);
    }
  }

  static Future<void> excluirItem(int id) async {
    final itens = await obterItens();
    itens.removeWhere((i) => i.id == id);
    await _salvarItens(itens);
  }

  // ===== HISTÓRICO =====

  static Future<List<Map<String, dynamic>>> obterHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('historico');
    if (jsonStr == null) return [];
    final List<dynamic> list = json.decode(jsonStr);
    return list.map((m) => Map<String, dynamic>.from(m)).toList();
  }

  static Future<void> registrarManutencao(
      int kmRealizado, String data, String itens) async {
    final historico = await obterHistorico();
    final newId = historico.isEmpty
        ? 1
        : historico
                .map((h) => h['id'] as int)
                .reduce((a, b) => a > b ? a : b) +
            1;
    historico.insert(0, {
      'id': newId,
      'km_realizado': kmRealizado,
      'data': data,
      'itens': itens,
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('historico', json.encode(historico));
  }
  
  static Future<void> concluirRevisao(
    List<ItemManutencao> itensRealizados,
    ) async {
    final moto = await obterMoto();

    final itensTexto =
        itensRealizados.map((e) => e.nome).join(', ');

    await registrarManutencao(
      moto.kmAtual,
      DateTime.now().toString(),
      itensTexto,
    );

    await atualizarMoto(
      moto.kmAtual,
      moto.kmAtual + 3000,
    );
  }

}