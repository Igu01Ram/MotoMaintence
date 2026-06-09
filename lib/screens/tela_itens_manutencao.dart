import 'package:flutter/material.dart';
import '../data/data_access_object.dart';
import '../models/item_manutencao.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe o nome do item!')));
      return;
    }
    final km = int.tryParse(_nomeKmController.text.trim()) ?? 0;

    await DataAccessObject.incluirItem(nome, kmRevisao: km);
    _nomeController.clear();
    _nomeKmController.clear();
    await _atualizarLista();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item adicionado com sucesso!')),
    );
  }

  Future<void> _excluirItem(ItemManutencao item) async {
    await DataAccessObject.excluirItem(item.id);
    await _atualizarLista();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Item "${item.nome}" excluído!')));
  }

  Future<void> _editarItem(ItemManutencao item) async {
    _editarController.text = item.nome;
    _editarKmController.text = item.kmRevisao > 0
        ? item.kmRevisao.toString()
        : '';

    final salvar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Editar Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _editarController,
              decoration: const InputDecoration(labelText: 'Nome do Item'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _editarKmController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'KM para revisão (ex: 3000)',
                prefixIcon: Icon(Icons.speed),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 48)),
            child: const Text('Salvar'),
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
        const SnackBar(content: Text('Item atualizado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2C2C2C)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Novo item de manutenção',
                      prefixIcon: Icon(Icons.build_circle_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nomeKmController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'KM para revisão (opcional)',
                      prefixIcon: Icon(Icons.speed),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _adicionarItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Item'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _itens.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.white24),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum item cadastrado.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _itens.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        var item = _itens[index];
                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF2C2C2C),
                              child: Icon(
                                Icons.settings,
                                color: Colors.deepOrangeAccent,
                              ),
                            ),
                            title: Text(
                              item.nome,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: item.kmRevisao > 0
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      'Revisão a cada ${item.kmRevisao} km',
                                      style: const TextStyle(
                                        color: Colors.orangeAccent,
                                      ),
                                    ),
                                  )
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.blueAccent,
                                  ),
                                  onPressed: () => _editarItem(item),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
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
