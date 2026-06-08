import 'package:flutter/material.dart';
import 'data_access_object.dart';
import 'item_manutencao.dart';
import 'tela_historico.dart';

class TelaRealizarRevisao extends StatefulWidget {
  const TelaRealizarRevisao({super.key});

  @override
  State<TelaRealizarRevisao> createState() => _TelaRealizarRevisaoState();
}

class _TelaRealizarRevisaoState extends State<TelaRealizarRevisao> {
  List<ItemManutencao> _itens = [];
  final Set<int> _selecionados = {};

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  Future<void> _carregarItens() async {
    final itens = await DataAccessObject.obterItens();

    if (!mounted) return;

    setState(() {
      _itens = itens;
    });
  }

  Future<void> _finalizarRevisao() async {
    if (_selecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione pelo menos um item da revisão.',
          ),
        ),
      );
      return;
    }

    try {
      final moto = await DataAccessObject.obterMoto();

      final itensRealizados = _itens
          .where((item) => _selecionados.contains(item.id))
          .map((e) => e.nome)
          .join(', ');

      await DataAccessObject.registrarManutencao(
        moto.kmAtual,
        DateTime.now().toString(),
        itensRealizados,
      );

      await DataAccessObject.atualizarMoto(
        moto.kmAtual,
        moto.kmAtual + 3000,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Manutenção registrada com sucesso!',
          ),
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(
        const Duration(seconds: 2),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const TelaHistorico(
            titulo: 'Histórico de Manutenções',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao salvar manutenção: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realizar Revisão'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _itens.length,
              itemBuilder: (context, index) {
                final item = _itens[index];

                return CheckboxListTile(
                  title: Text(item.nome),
                  value: _selecionados.contains(item.id),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selecionados.add(item.id);
                      } else {
                        _selecionados.remove(item.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _finalizarRevisao,
                icon: const Icon(Icons.check),
                label: const Text('FINALIZAR REVISÃO'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}