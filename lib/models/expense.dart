class Expense {
  final int? id;
  final String description;
  final double value;
  final DateTime date;
  final int updatedAtMillis; // suporte futuro à sincronização
  final bool isDeleted; // soft delete para futuras estratégias

  Expense({
    this.id,
    required this.description,
    required this.value,
    required this.date,
    int? updatedAtMillis,
    this.isDeleted = false,
  }) : updatedAtMillis =
           updatedAtMillis ?? DateTime.now().millisecondsSinceEpoch;

  Expense copyWith({
    int? id,
    String? description,
    double? value,
    DateTime? date,
    int? updatedAtMillis,
    bool? isDeleted,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      value: value ?? this.value,
      date: date ?? this.date,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'description': description,
      'value': value,
      'date': date.toIso8601String(),
      'updated_at': updatedAtMillis,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Expense.fromMap(Map<String, Object?> map) {
    return Expense(
      id: map['id'] as int?,
      description: map['description'] as String? ?? '',
      value: (map['value'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(
        map['date'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAtMillis:
          (map['updated_at'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      isDeleted: ((map['is_deleted'] as num?)?.toInt() ?? 0) == 1,
    );
  }
}
