import 'dart:convert';
import 'package:cross_file/cross_file.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/expense.dart';

Future<void> exportExpensesCsv(List<Expense> items) async {
  final rows = <List<String>>[
    ['id', 'title', 'amount', 'date', 'category'],
    ...items.map((e) => [
          (e.id ?? '').toString(),
          e.title,
          e.amount.toStringAsFixed(2),
          e.date,
          e.category,
        ]),
  ];

  String escape(String v) {
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  final csv = rows.map((r) => r.map(escape).join(',')).join('\n');
  final bytes = utf8.encode(csv);

  final file = XFile.fromData(
    bytes,
    mimeType: 'text/csv',
    name: 'spendwise_expenses.csv',
  );

  await Share.shareXFiles([file], text: 'SpendWise expenses export');
}
