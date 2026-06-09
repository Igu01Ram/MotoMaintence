import 'package:flutter/material.dart';
import 'data_access_object.dart';
import 'moto.dart';
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
    await DataAccessObject.incrementarKm(10);
    await _carregarDados();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('KM incrementado em 10!')),
    );

    _verificarManutencao();
  }

  void _verificarManutencao() {
    if (_moto != null && _moto!.kmAtual >= _moto!.kmManutencao) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Atenção!'),
          content: Text(
            'A quilometragem atual (${_moto!.kmAtual} km) atingiu ou ultrapassou '
            'a quilometragem de manutenção (${_moto!.kmManutencao} km).\n\n'
            'Realize a manutenção da sua moto!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Fechar'),
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
              child: const Text('Ir para Revisão'),
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
        title: const Text('Manutenção de Moto'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.two_wheeler, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Manutenção de Moto',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Tela Principal'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Itens de Manutenção'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaItensManutencao(
                      titulo: 'Itens de Manutenção',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Histórico'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaHistorico(
                      titulo: 'Histórico de Manutenções',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Simulação'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaRealizarRevisao(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fundo.png'), // Alterado de .jpg para .png aqui!
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_moto != null)
                  Card(
                    color: Colors.white.withOpacity(0.85),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.speed, size: 48, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 8),
                          Text(
                            '${_moto!.kmAtual} km',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const Text(
                            'Quilometragem Atual',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                TextField(
                  controller: kmAtualController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'KM Atual da Moto',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.speed),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: kmManutencaoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'KM da Próxima Manutenção',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.build),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _salvarInformacoes,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Informações'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _incrementarKm,
                  icon: const Icon(Icons.add),
                  label: const Text('Incrementar KM (+10)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}