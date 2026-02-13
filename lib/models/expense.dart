class Expense {
  final int? id;
  final String title;
  final double amount;
  final String date; // yyyy-MM-dd
  final String category; // Food, Transport, Shopping, Other

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    String? date,
    String? category,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
      'category': category,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String,
      category: (map['category'] as String?) ?? 'Other',
    );
  }
}
