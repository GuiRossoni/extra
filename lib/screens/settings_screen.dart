import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _prefs = PreferencesService();
  final _limitController = TextEditingController();
  final _currencies = const ['R\$', '€', '\$'];
  String _currency = 'R\$';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final currency = await _prefs.getCurrency();
    final limit = await _prefs.getDailyLimit();
    setState(() {
      _currency = _currencies.contains(currency) ? currency : 'R\$';
      _limitController.text = limit.toStringAsFixed(2);
      _loading = false;
    });
  }

  Future<void> _save() async {
    final limit =
        double.tryParse(_limitController.text.replaceAll(',', '.')) ?? 0.0;
    await _prefs.setCurrency(_currency);
    await _prefs.setDailyLimit(limit);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preferências salvas')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Moeda padrão'),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _currency,
                    items: _currencies
                        .map(
                          (c) => DropdownMenuItem<String>(
                            value: c,
                            child: Text(c),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _currency = v ?? 'R\$'),
                  ),
                  const SizedBox(height: 24),
                  const Text('Limite diário de gastos'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _limitController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '0.00',
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
