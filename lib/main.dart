import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/expense_list_screen.dart';

void main() {
  // Inicializa FFI do sqflite para desktop (Windows/Linux)
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const TravelExpensesApp());
}

class TravelExpensesApp extends StatelessWidget {
  const TravelExpensesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Gastos de Viagem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ExpenseListScreen(),
    );
  }
}
