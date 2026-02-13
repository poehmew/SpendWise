import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import 'expense_store.dart';

class _PrefsExpenseStore implements ExpenseStore {
  static const _key = 'spendwise_expenses';
  late SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<Map<String, dynamic>> _readRaw() {
    final s = _prefs.getString(_key);
    if (s == null || s.isEmpty) return [];
    final list = jsonDecode(s) as List<dynamic>;
    return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  Future<void> _writeRaw(List<Map<String, dynamic>> raw) async {
    await _prefs.setString(_key, jsonEncode(raw));
  }

  int _nextId(List<Map<String, dynamic>> raw) {
    final ids = raw.map((e) => (e['id'] as int?) ?? 0).toList();
    final maxId = ids.isEmpty ? 0 : ids.reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  @override
  Future<List<Expense>> getAll() async {
    final raw = _readRaw();
    final items = raw.map(Expense.fromMap).toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  Future<Expense> insert(Expense expense) async {
    final raw = _readRaw();
    final id = expense.id ?? _nextId(raw);
    final saved = expense.copyWith(id: id);
    raw.add(saved.toMap().cast<String, dynamic>());
    await _writeRaw(raw);
    return saved;
  }

  @override
  Future<void> update(Expense expense) async {
    if (expense.id == null) return;
    final raw = _readRaw();
    final idx = raw.indexWhere((e) => e['id'] == expense.id);
    if (idx == -1) return;
    raw[idx] = expense.toMap().cast<String, dynamic>();
    await _writeRaw(raw);
  }

  @override
  Future<void> delete(int id) async {
    final raw = _readRaw();
    raw.removeWhere((e) => e['id'] == id);
    await _writeRaw(raw);
  }
}

ExpenseStore createStore() => _PrefsExpenseStore();
