import 'package:flutter/material.dart';
import 'tela_principal.dart';

class MotoManutencaoApp extends StatelessWidget {
  const MotoManutencaoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manutenção de Moto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: TelaPrincipal(),
    );
  }
}