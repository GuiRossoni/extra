import 'package:flutter/material.dart';
import '../models/expense.dart';

class DailyLimitBanner extends StatelessWidget {
  final List<Expense> expenses;
  final double dailyLimit;
  final String currency;

  const DailyLimitBanner({
    super.key,
    required this.expenses,
    required this.dailyLimit,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyLimit <= 0) return const SizedBox.shrink();
    final now = DateTime.now();
    isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    final todayTotal = expenses
        .where((e) => isSameDay(e.date, now))
        .fold<double>(0.0, (sum, e) => sum + e.value);
    final over = todayTotal > dailyLimit;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        color: over
            ? Colors.red.withOpacity(0.12)
            : Colors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: over ? Colors.redAccent : Colors.green),
      ),
      child: Row(
        children: [
          Icon(
            over ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            color: over ? Colors.redAccent : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              over
                  ? 'Hoje: $currency ${todayTotal.toStringAsFixed(2)} • Limite: $currency ${dailyLimit.toStringAsFixed(2)} (excedido)'
                  : 'Hoje: $currency ${todayTotal.toStringAsFixed(2)} • Limite: $currency ${dailyLimit.toStringAsFixed(2)}',
              style: TextStyle(
                color: over ? Colors.redAccent : Colors.green.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
