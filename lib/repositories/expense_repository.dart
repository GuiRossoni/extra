import '../db/app_database.dart';
import '../models/expense.dart';

class ExpenseRepository {
  Future<int> addExpense(Expense expense) async {
    final db = await AppDatabase().database;
    return db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getAllExpenses({bool includeDeleted = false}) async {
    final db = await AppDatabase().database;
    final where = includeDeleted ? null : 'is_deleted = 0';
    final maps = await db.query('expenses', where: where);
    return maps.map((m) => Expense.fromMap(m)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<int> updateExpense(Expense expense) async {
    if (expense.id == null) throw ArgumentError('Expense id is required');
    final db = await AppDatabase().database;
    final updated = expense.copyWith(
      updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    return db.update(
      'expenses',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> softDeleteExpense(int id) async {
    final db = await AppDatabase().database;
    return db.update(
      'expenses',
      {'is_deleted': 1, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
