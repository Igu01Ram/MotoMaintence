import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/data_access_object.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _historico.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 64,
                    color: Colors.white24,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma manutenção registrada.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: _historico.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                var registro = _historico[index];

                String dataFormatada = registro['data'] ?? '';
                try {
                  DateTime data = DateTime.parse(registro['data']);
                  dataFormatada = DateFormat(
                    "dd/MM/yyyy 'às' HH:mm",
                  ).format(data);
                } catch (e) {}

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF2C2C2C),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent,
                      ),
                    ),
                    title: Text(
                      '${registro['km_realizado']} km',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data: $dataFormatada',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Itens: ${registro['itens']}',
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
