import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../services/preferences_service.dart';
import 'settings_screen.dart';
import '../widgets/expense_tile.dart';
import '../widgets/daily_limit_banner.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _repo = ExpenseRepository();
  final _prefs = PreferencesService();
  late Future<List<Expense>> _future;
  String _currency = 'R\$';
  double _dailyLimit = 0.0;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _repo.getAllExpenses();
    _prefs.getCurrency().then((c) => setState(() => _currency = c));
    _prefs.getDailyLimit().then((l) => setState(() => _dailyLimit = l));
    setState(() {});
  }

  Future<void> _addExpenseDialog() async {
    final descCtrl = TextEditingController();
    final valCtrl = TextEditingController();
    DateTime date = DateTime.now();
    final res = await showDialog<Expense>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Despesa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            TextField(
              controller: valCtrl,
              decoration: const InputDecoration(labelText: 'Valor'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Data:'),
                const SizedBox(width: 8),
                Text(DateFormat('dd/MM/yyyy').format(date)),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: date,
                    );
                    if (picked != null) {
                      date = picked;
                      // Force rebuild of the dialog
                      (ctx as Element).markNeedsBuild();
                    }
                  },
                  child: const Text('Selecionar'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(valCtrl.text.replaceAll(',', '.'));
              if ((descCtrl.text).isEmpty || value == null) return;
              Navigator.pop(
                ctx,
                Expense(
                  description: descCtrl.text.trim(),
                  value: value,
                  date: date,
                ),
              );
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    if (res != null) {
      await _repo.addExpense(res);
      _reload();
    }
  }

  Future<void> _editExpenseDialog(Expense e) async {
    final descCtrl = TextEditingController(text: e.description);
    final valCtrl = TextEditingController(text: e.value.toStringAsFixed(2));
    DateTime date = e.date;
    final res = await showDialog<Expense>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Despesa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            TextField(
              controller: valCtrl,
              decoration: const InputDecoration(labelText: 'Valor'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Data:'),
                const SizedBox(width: 8),
                Text(DateFormat('dd/MM/yyyy').format(date)),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: date,
                    );
                    if (picked != null) {
                      date = picked;
                      (ctx as Element).markNeedsBuild();
                    }
                  },
                  child: const Text('Selecionar'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(valCtrl.text.replaceAll(',', '.'));
              if ((descCtrl.text).isEmpty || value == null) return;
              Navigator.pop(
                ctx,
                e.copyWith(
                  description: descCtrl.text.trim(),
                  value: value,
                  date: date,
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (res != null) {
      await _repo.updateExpense(res);
      _reload();
    }
  }

  Future<void> _deleteExpense(Expense e) async {
    if (e.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir despesa'),
        content: Text('Deseja excluir "${e.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _repo.softDeleteExpense(e.id!);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Despesa excluída')));
      }
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Despesas da Viagem'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              _reload();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Expense>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('Nenhuma despesa cadastrada'));
          }
          return Column(
            children: [
              DailyLimitBanner(
                expenses: items,
                dailyLimit: _dailyLimit,
                currency: _currency,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final e = items[index];
                    final currency = _currency;
                    return Dismissible(
                      key: ValueKey(
                        e.id ?? '${e.description}-${e.date.toIso8601String()}',
                      ),
                      background: Container(color: Colors.redAccent),
                      onDismissed: (_) => _deleteExpense(e),
                      child: ExpenseTile(
                        expense: e,
                        currency: currency,
                        onTap: () => _editExpenseDialog(e),
                        onEdit: () => _editExpenseDialog(e),
                        onDelete: () => _deleteExpense(e),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpenseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
