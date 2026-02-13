import 'package:flutter/foundation.dart';
import '../data/expense_store.dart';
import '../models/expense.dart';

class ExpensesController extends ChangeNotifier {
  final ExpenseStore store;

  ExpensesController(this.store);

  List<Expense> _items = [];
  List<Expense> get items => _items;

  Future<void> init() async {
    await store.init();
    await load();
  }

  Future<void> load() async {
    _items = await store.getAll();
    notifyListeners();
  }

  /// ✅ used by AppShell
  Future<void> insert(Expense e) async {
    await store.insert(e);
    await load();
  }

  /// Optional if your store supports update
  Future<void> update(Expense e) async {
    try {
      // if your ExpenseStore has update, it will work
      // ignore: invalid_use_of_visible_for_testing_member
      await (store as dynamic).update(e);
      await load();
    } catch (_) {
      // if not supported, silently ignore
    }
  }

  Future<void> delete(int id) async {
    await store.delete(id);
    await load();
  }
}

