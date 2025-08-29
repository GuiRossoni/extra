import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final String currency;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ExpenseTile({
    super.key,
    required this.expense,
    required this.currency,
    this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final amount = Text('$currency ${expense.value.toStringAsFixed(2)}');
    Widget trailing;
    if (onDelete != null || onEdit != null) {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          amount,
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit' && onEdit != null) onEdit!();
              if (value == 'delete' && onDelete != null) onDelete!();
            },
            itemBuilder: (context) => [
              if (onEdit != null)
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
              if (onDelete != null)
                const PopupMenuItem(value: 'delete', child: Text('Excluir')),
            ],
          ),
        ],
      );
    } else {
      trailing = amount;
    }

    return ListTile(
      title: Text(expense.description),
      subtitle: Text(DateFormat('dd/MM/yyyy').format(expense.date)),
      trailing: trailing,
      onTap: onTap,
      onLongPress: onDelete, // atalho: segurar para excluir
    );
  }
}
