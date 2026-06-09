import 'package:flutter/material.dart';
import '../data/data_access_object.dart';
import '../models/moto.dart';
import 'tela_itens_manutencao.dart';
import 'tela_historico.dart';
import 'tela_realizar_revisao.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  var kmAtualController = TextEditingController();
  var kmManutencaoController = TextEditingController();
  Moto? _moto;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    var moto = await DataAccessObject.obterMoto();
    setState(() {
      _moto = moto;
      kmAtualController.text = moto.kmAtual.toString();
      kmManutencaoController.text = moto.kmManutencao.toString();
    });
  }

  Future<void> _salvarInformacoes() async {
    var kmAtualTexto = kmAtualController.text;
    var kmManutencaoTexto = kmManutencaoController.text;

    if (kmAtualTexto.isEmpty || kmManutencaoTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos!')),
      );
      return;
    }

    var kmAtual = int.tryParse(kmAtualTexto);
    var kmManutencao = int.tryParse(kmManutencaoTexto);

    if (kmAtual == null || kmManutencao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe valores numéricos válidos!')),
      );
      return;
    }

    await DataAccessObject.atualizarMoto(kmAtual, kmManutencao);
    await _carregarDados();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informações salvas com sucesso!')),
    );

    _verificarManutencao();
  }

  Future<void> _incrementarKm() async {
    final controller = TextEditingController();
    final valor = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Adicionar Quilometragem'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Quantos KMs você rodou?',
            prefixIcon: Icon(Icons.add_road),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              Navigator.pop(context, val);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 48)),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (valor != null && valor > 0) {
      await DataAccessObject.incrementarKm(valor);
      await _carregarDados();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foram adicionados $valor km com sucesso!')),
      );

      _verificarManutencao();
    }
  }

  void _verificarManutencao() {
    if (_moto != null && _moto!.kmAtual >= _moto!.kmManutencao) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text(
            'Revisão Necessária!',
            style: TextStyle(color: Colors.deepOrangeAccent),
          ),
          content: Text(
            'A quilometragem atual (${_moto!.kmAtual} km) atingiu ou ultrapassou '
            'a marca de manutenção (${_moto!.kmManutencao} km).\n\n'
            'Está na hora de dar aquele talento na moto!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Agora Não',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TelaRealizarRevisao(),
                  ),
                );
                await _carregarDados();
              },
              child: const Text('Fazer Revisão'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Garagem',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF121212),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 64,
                bottom: 32,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.only(topRight: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepOrangeAccent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.two_wheeler,
                      size: 48,
                      color: Colors.deepOrangeAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'MotoMain App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sua Garagem Digital',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildDrawerItem(
                    Icons.home_outlined,
                    'Página Inicial',
                    () => Navigator.pop(context),
                    true,
                  ),
                  _buildDrawerItem(
                    Icons.build_circle_outlined,
                    'Itens de Manutenção',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TelaItensManutencao(
                            titulo: 'Itens de Manutenção',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(Icons.history, 'Histórico', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const TelaHistorico(titulo: 'Histórico'),
                      ),
                    );
                  }),
                  _buildDrawerItem(
                    Icons.handyman_outlined,
                    'Realizar Revisão',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TelaRealizarRevisao(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Versão 1.0.0',
                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_moto != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.speed,
                          size: 40,
                          color: Colors.deepOrangeAccent,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_moto!.kmAtual} km',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Quilometragem Atual',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Próxima Revisão: ${_moto!.kmManutencao} km',
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Builder(
                          builder: (context) {
                            int kmFaltante =
                                _moto!.kmManutencao - _moto!.kmAtual;
                            double progresso =
                                1.0 - (kmFaltante / 3000.0).clamp(0.0, 1.0);

                            Color corBarra = Colors.greenAccent;
                            if (kmFaltante <= 500)
                              corBarra = Colors.orangeAccent;
                            if (kmFaltante <= 100) corBarra = Colors.redAccent;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Progresso do Ciclo',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      kmFaltante > 0
                                          ? 'Faltam $kmFaltante km'
                                          : 'Manutenção Atrasada!',
                                      style: TextStyle(
                                        color: kmFaltante > 0
                                            ? Colors.grey
                                            : Colors.redAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: progresso,
                                    minHeight: 12,
                                    backgroundColor: const Color(0xFF2C2C2C),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      corBarra,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              TextField(
                controller: kmAtualController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Atualizar KM Atual',
                  prefixIcon: Icon(Icons.edit_road),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: kmManutencaoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Meta da Próxima Revisão',
                  prefixIcon: Icon(Icons.build_circle),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _salvarInformacoes,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Salvar Alterações'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _incrementarKm,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Adicionar KM Rodados'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF2C2C2C), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, [
    bool isSelected = false,
  ]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.deepOrangeAccent.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(
          icon,
          color: isSelected ? Colors.deepOrangeAccent : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.deepOrangeAccent : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
