import 'package:flutter/material.dart';
import '../data/data_access_object.dart';
import '../models/item_manutencao.dart';
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
        title: const Text('Realizar Revisão', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _itens.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _itens[index];
                final isSelected = _selecionados.contains(item.id);

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (!isSelected) {
                        _selecionados.add(item.id);
                      } else {
                        _selecionados.remove(item.id);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepOrangeAccent.withValues(alpha: 0.1) : const Color(0xFF1E1E1E),
                      border: Border.all(
                        color: isSelected ? Colors.deepOrangeAccent : const Color(0xFF2C2C2C),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CheckboxListTile(
                      activeColor: Colors.deepOrangeAccent,
                      checkColor: Colors.white,
                      title: Text(
                        item.nome,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selecionados.add(item.id);
                          } else {
                            _selecionados.remove(item.id);
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton.icon(
              onPressed: _finalizarRevisao,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('FINALIZAR REVISÃO'),
            ),
          ),
        ],
      ),
    );
  }
}