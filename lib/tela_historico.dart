import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'data_access_object.dart';
import 'item_manutencao.dart';

// Tela que recebe o parâmetro "titulo" para exibir no AppBar
class TelaHistorico extends StatefulWidget {
  final String titulo;

  const TelaHistorico({super.key, required this.titulo});

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  List<Map<String, dynamic>> _historico = [];

  @override
  void initState() {
    super.initState();
    _atualizarHistorico();
  }

  Future<void> _atualizarHistorico() async {
    var historico = await DataAccessObject.obterHistorico();
    setState(() {
      _historico = historico;
    });
  }

  Future<List<ItemManutencao>?> _selecionarItensManutencao(
    List<ItemManutencao> itens,
  ) async {
    final itensSelecionados = <int>{};

    return showDialog<List<ItemManutencao>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Selecionar manutenção feita'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: itens.map((item) {
                      return CheckboxListTile(
                        value: itensSelecionados.contains(item.id),
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.nome),
                        subtitle: item.kmRevisao > 0
                            ? Text('Intervalo: ${item.kmRevisao} km')
                            : null,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          setDialogState(() {
                            if (value ?? false) {
                              itensSelecionados.add(item.id);
                            } else {
                              itensSelecionados.remove(item.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final selecionados = itens
                        .where((item) => itensSelecionados.contains(item.id))
                        .toList();
                    Navigator.pop(dialogContext, selecionados);
                  },
                  child: const Text('Registrar'),
                ),
              ],
            );
          },
        );
      },
    );
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
            // Lista do histórico
            Expanded(
              child: _historico.isEmpty
                  ? Center(child: Text('Nenhuma manutenção registrada.'))
                  : ListView.builder(
                      itemCount: _historico.length,
                      itemBuilder: (context, index) {
                        var registro = _historico[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.check_circle,
                                color: Colors.green),
                            title: Text('${registro['km_realizado']} km'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Data: ${registro['data']}'),
                                Text('Itens: ${registro['itens']}'),
                              ],
                            ),
                            isThreeLine: true,
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
