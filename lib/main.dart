import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'moto_manutencao_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MotoManutencaoApp());
}
