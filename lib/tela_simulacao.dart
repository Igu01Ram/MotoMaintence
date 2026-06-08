import 'dart:async';
import 'package:flutter/material.dart';
import 'data_access_object.dart';
import 'item_manutencao.dart';
import 'tela_realizar_revisao.dart';

class TelaSimulacao extends StatefulWidget {
  const TelaSimulacao({super.key});

  @override
  State<TelaSimulacao> createState() => _TelaSimulacaoState();
}

class _TelaSimulacaoState extends State<TelaSimulacao> {
  double _velocidade = 0.0;
  double _kmPercorrido = 0.0;
  double _kmTotal = 0.0;
  int _kmManutencao = 1000;

  bool _acelerando = false;
  bool _freando = false;
  bool _mostrandoAlerta = false;

  Timer? _timer;

  final Set<String> _alertasExibidos = {};
  List<ItemManutencao> _itensComKm = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _iniciarTimer();
  }

  Future<void> _carregarDados() async {
    final moto = await DataAccessObject.obterMoto();
    final itens = await DataAccessObject.obterItens();
    if (!mounted) return;
    setState(() {
      _kmTotal = moto.kmAtual.toDouble();
      _kmManutencao = moto.kmManutencao;
      _itensComKm = itens.where((i) => i.kmRevisao > 0).toList()
        ..sort((a, b) => a.kmRevisao.compareTo(b.kmRevisao));
    });
  }

  void _iniciarTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        if (_acelerando) {
          _velocidade = (_velocidade + 8).clamp(0, 200);
        } else if (_freando) {
          _velocidade = (_velocidade - 15).clamp(0, 200);
        } else {
          _velocidade = (_velocidade - 3).clamp(0, 200);
        }

        if (_velocidade > 0) {
          final kmAnterior = _kmTotal;
          final inc = _velocidade * 0.8;
          _kmPercorrido += inc;
          _kmTotal += inc;
          _verificarMarcos(kmAnterior, _kmTotal);
        }
      });
    });
  }

  void _verificarMarcos(double kmAnterior, double kmAtual) {
    if (_mostrandoAlerta) return;
    for (final item in _itensComKm) {
      final intervalo = item.kmRevisao;
      if (intervalo <= 0) continue;

      final proximoMarco = ((kmAnterior ~/ intervalo) + 1) * intervalo;
      final chaveAlerta = '${item.id}:$proximoMarco';

      if (proximoMarco <= kmAtual && !_alertasExibidos.contains(chaveAlerta)) {
        _alertasExibidos.add(chaveAlerta);
        _mostrandoAlerta = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mostrarAlerta(item.nome, proximoMarco);
        });
        break;
      }
    }
  }

  void _mostrarAlerta(String descricao, int km) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.build_circle, size: 52, color: Colors.orange),
        title: const Text(
          'Manutenção Necessária!',
          textAlign: TextAlign.center,
        ),
        content: Text(
          '${_kmTotal.toInt()} km atuais.\n\n'
          'Revisão prevista para $km km:\n$descricao',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _mostrandoAlerta = false;
            },
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _mostrandoAlerta = false;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TelaRealizarRevisao(),
                ),
              );
            },
            child: const Text('Ir para Manutenção'),
          ),
        ],
      ),
    );
  }

  Future<void> _salvarKm() async {
    await DataAccessObject.atualizarMoto(_kmTotal.toInt(), _kmManutencao);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _salvarKm();
    super.dispose();
  }


  Map<String, dynamic>? get _proximoMarco {
    Map<String, dynamic>? proximo;

    for (final item in _itensComKm) {
      final proximoKm = (((_kmTotal.toInt()) ~/ item.kmRevisao) + 1) * item.kmRevisao;
      if (proximo == null || proximoKm < (proximo['km'] as int)) {
        proximo = {'item': item, 'km': proximoKm};
      }
    }

    return proximo;
  }


  @override
  Widget build(BuildContext context) {
    final proximo = _proximoMarco;
    final semItens = _itensComKm.isEmpty;
    final proximoItem = proximo?['item'] as ItemManutencao?;
    final proximoKm = proximo?['km'] as int?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulação'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Velocímetro ──
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(Icons.speed, size: 40, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 8),
                    Text(
                      '${_velocidade.toInt()} km/h',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const Text('Velocidade', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── KM ──
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Icon(Icons.route, color: Colors.grey[600]),
                          const SizedBox(height: 4),
                          Text(
                            '${_kmTotal.toInt()} km',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text('KM Total', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Icon(Icons.pin_drop, color: Colors.grey[600]),
                          const SizedBox(height: 4),
                          Text(
                            '${_kmPercorrido.toInt()} km',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text('Percorridos', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Próxima manutenção ──
            if (semItens)
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cadastre itens com KM de revisão para receber alertas.',
                          style: TextStyle(color: Colors.blue[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (proximo != null)
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.build_circle, color: Colors.orange[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Próxima: ${proximoItem!.nome} em ${(proximoKm! - _kmTotal).toInt()} km',
                          style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Todos os itens com KM de revisão já foram atingidos nesta simulação.',
                          style: TextStyle(color: Colors.green[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // ── Botões ──
            Row(
              children: [
                Expanded(
                  child: _buildBotao(
                    'Freio',
                    Colors.red,
                    _freando,
                    onDown: () => setState(() { _freando = true; _acelerando = false; }),
                    onUp: () => setState(() => _freando = false),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBotao(
                    'Acelerar',
                    Colors.green,
                    _acelerando,
                    onDown: () => setState(() { _acelerando = true; _freando = false; }),
                    onUp: () => setState(() => _acelerando = false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotao(
    String label,
    Color cor,
    bool ativo, {
    required VoidCallback onDown,
    required VoidCallback onUp,
  }) {
    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ativo ? cor : cor.withValues(alpha: 0.15),
          border: Border.all(color: cor, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: ativo ? Colors.white : cor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
