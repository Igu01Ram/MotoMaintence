import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/moto.dart';
import '../models/item_manutencao.dart';

class DataAccessObject {
  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'moto_maintence.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE moto (
            id INTEGER PRIMARY KEY,
            km_atual INTEGER,
            km_manutencao INTEGER
          )
        ''');
        
        await db.execute('''
          CREATE TABLE item_manutencao (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            km_revisao INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE historico (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            km_realizado INTEGER,
            data TEXT,
            itens TEXT
          )
        ''');

        // Moto padrão
        await db.insert('moto', {
          'id': 1,
          'km_atual': 0,
          'km_manutencao': 1000
        });

        // Itens de manutenção padrões
        final defaultItens = [
          {'nome': 'Óleo', 'km_revisao': 0},
          {'nome': 'Pneu', 'km_revisao': 0},
          {'nome': 'Filtro de Óleo', 'km_revisao': 0},
          {'nome': 'Pastilha de Freio', 'km_revisao': 0},
          {'nome': 'Corrente', 'km_revisao': 0},
          {'nome': 'Vela', 'km_revisao': 0},
        ];
        for (var item in defaultItens) {
          await db.insert('item_manutencao', item);
        }
      },
    );
    return _db!;
  }

  // ===== MOTO =====

  static Future<Moto> obterMoto() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('moto', where: 'id = ?', whereArgs: [1]);
    if (maps.isNotEmpty) {
      return Moto(
        id: maps[0]['id'],
        kmAtual: maps[0]['km_atual'],
        kmManutencao: maps[0]['km_manutencao'],
      );
    }
    return Moto(id: 1, kmAtual: 0, kmManutencao: 1000);
  }

  static Future<void> atualizarMoto(int kmAtual, int kmManutencao) async {
    final db = await getDatabase();
    await db.update(
      'moto',
      {'km_atual': kmAtual, 'km_manutencao': kmManutencao},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  static Future<void> incrementarKm(int incremento) async {
    final moto = await obterMoto();
    await atualizarMoto(moto.kmAtual + incremento, moto.kmManutencao);
  }

  // ===== ITENS DE MANUTENÇÃO =====

  static Future<List<ItemManutencao>> obterItens() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('item_manutencao');
    return List.generate(maps.length, (i) {
      return ItemManutencao(
        id: maps[i]['id'],
        nome: maps[i]['nome'],
        kmRevisao: maps[i]['km_revisao'],
      );
    });
  }

  static Future<void> incluirItem(String nome, {int kmRevisao = 0}) async {
    final db = await getDatabase();
    await db.insert('item_manutencao', {
      'nome': nome,
      'km_revisao': kmRevisao,
    });
  }

  static Future<void> atualizarItem(int id, String nome, {int kmRevisao = 0}) async {
    final db = await getDatabase();
    await db.update(
      'item_manutencao',
      {
        'nome': nome,
        'km_revisao': kmRevisao,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> excluirItem(int id) async {
    final db = await getDatabase();
    await db.delete(
      'item_manutencao',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== HISTÓRICO =====

  static Future<List<Map<String, dynamic>>> obterHistorico() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('historico', orderBy: 'id DESC');
    return List.generate(maps.length, (i) {
      return {
        'id': maps[i]['id'],
        'km_realizado': maps[i]['km_realizado'],
        'data': maps[i]['data'],
        'itens': maps[i]['itens'],
      };
    });
  }

  static Future<void> registrarManutencao(
      int kmRealizado, String data, String itens) async {
    final db = await getDatabase();
    await db.insert('historico', {
      'km_realizado': kmRealizado,
      'data': data,
      'itens': itens,
    });
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