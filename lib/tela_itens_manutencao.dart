import 'package:flutter/material.dart';
import 'data_access_object.dart';
import 'item_manutencao.dart';

// Tela que recebe o parâmetro "titulo" para exibir no AppBar
class TelaItensManutencao extends StatefulWidget {
  final String titulo;

  const TelaItensManutencao({super.key, required this.titulo});

  @override
  State<TelaItensManutencao> createState() => _TelaItensManutencaoState();
}

class _TelaItensManutencaoState extends State<TelaItensManutencao> {
  final _nomeController = TextEditingController();
  final _nomeKmController = TextEditingController();
  final _editarController = TextEditingController();
  final _editarKmController = TextEditingController();
  List<ItemManutencao> _itens = [];

  @override
  void initState() {
    super.initState();
    _atualizarLista();
  }

  Future<void> _atualizarLista() async {
    var itens = await DataAccessObject.obterItens();
    setState(() {
      _itens = itens;
    });
  }

  Future<void> _adicionarItem() async {
    var nome = _nomeController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Informe o nome do item!')),
      );
      return;
    }
    final km = int.tryParse(_nomeKmController.text.trim()) ?? 0;

    await DataAccessObject.incluirItem(nome, kmRevisao: km);
    _nomeController.clear();
    _nomeKmController.clear();
    await _atualizarLista();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item adicionado com sucesso!')),
    );
  }

  Future<void> _excluirItem(ItemManutencao item) async {
    await DataAccessObject.excluirItem(item.id);
    await _atualizarLista();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item "${item.nome}" excluído!')),
    );
  }

  Future<void> _editarItem(ItemManutencao item) async {
    _editarController.text = item.nome;
    _editarKmController.text = item.kmRevisao > 0 ? item.kmRevisao.toString() : '';

    final salvar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _editarController,
              decoration: InputDecoration(
                labelText: 'Nome do Item',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _editarKmController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'KM para revisão (ex: 3000)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.speed),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Salvar'),
          ),
        ],
      ),
    );

    if (salvar == true && _editarController.text.trim().isNotEmpty) {
      final km = int.tryParse(_editarKmController.text.trim()) ?? 0;
      await DataAccessObject.atualizarItem(
        item.id,
        _editarController.text.trim(),
        kmRevisao: km,
      );
      await _atualizarLista();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item atualizado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo para adicionar novo item
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          labelText: 'Novo item de manutenção',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _nomeKmController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'KM para revisão (opcional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.speed),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _adicionarItem,
                  child: Icon(Icons.add),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Lista de itens
            Expanded(
              child: _itens.isEmpty
                  ? Center(child: Text('Nenhum item cadastrado.'))
                  : ListView.builder(
                      itemCount: _itens.length,
                      itemBuilder: (context, index) {
                        var item = _itens[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.settings),
                            title: Text(item.nome),
                            subtitle: item.kmRevisao > 0
                                ? Text('Revisão a cada ${item.kmRevisao} km',
                                    style: TextStyle(color: Colors.orange[700]))
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editarItem(item),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _excluirItem(item),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
