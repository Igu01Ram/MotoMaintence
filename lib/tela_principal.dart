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
        SnackBar(content: Text('Preencha todos os campos!')),
      );
      return;
    }

    var kmAtual = int.tryParse(kmAtualTexto);
    var kmManutencao = int.tryParse(kmManutencaoTexto);

    if (kmAtual == null || kmManutencao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Informe valores numéricos válidos!')),
      );
      return;
    }

    await DataAccessObject.atualizarMoto(kmAtual, kmManutencao);
    await _carregarDados();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Informações salvas com sucesso!')),
    );

    _verificarManutencao();
  }

  Future<void> _incrementarKm() async {
    await DataAccessObject.incrementarKm(10);
    await _carregarDados();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('KM incrementado em 10!')),
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

  // void _verificarManutencao() {
  //   if (_moto != null && _moto!.kmAtual >= _moto!.kmManutencao) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Text('Atenção!'),
  //         content: Text(
  //           'A quilometragem atual (${_moto!.kmAtual} km) atingiu ou ultrapassou '
  //           'a quilometragem de manutenção (${_moto!.kmManutencao} km).\n\n'
  //           'Realize a manutenção da sua moto!',
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: Text('OK'),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manutenção de Moto'),
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
              child: Column(
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
              leading: Icon(Icons.home),
              title: Text('Tela Principal'),
              onTap: () {
                Navigator.pop(context); // fecha o drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.build),
              title: Text('Itens de Manutenção'),
              onTap: () {
                Navigator.pop(context); // fecha o drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TelaItensManutencao(
                      titulo: 'Itens de Manutenção',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Histórico'),
              onTap: () {
                Navigator.pop(context); // fecha o drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TelaHistorico(
                      titulo: 'Histórico de Manutenções',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.directions_car),
              title: Text('Simulação'),
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Exibir KM atual da moto
            if (_moto != null)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.speed, size: 48, color: Theme.of(context).colorScheme.primary),
                      SizedBox(height: 8),
                      Text(
                        '${_moto!.kmAtual} km',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      Text('Quilometragem Atual'),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 16),

            // Campo KM Atual
            TextField(
              controller: kmAtualController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'KM Atual da Moto',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.speed),
              ),
            ),
            SizedBox(height: 16),

            // Campo KM Manutenção
            TextField(
              controller: kmManutencaoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'KM da Próxima Manutenção',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.build),
              ),
            ),
            SizedBox(height: 24),

            // Botão Salvar Informações
            ElevatedButton.icon(
              onPressed: _salvarInformacoes,
              icon: Icon(Icons.save),
              label: Text('Salvar Informações'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 12),

            // Botão Incrementar KM
            ElevatedButton.icon(
              onPressed: _incrementarKm,
              icon: Icon(Icons.add),
              label: Text('Incrementar KM (+10)'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
