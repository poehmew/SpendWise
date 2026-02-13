import '../models/expense.dart';

import 'expense_store_io.dart'
    if (dart.library.html) 'expense_store_web.dart';

abstract class ExpenseStore {
  Future<void> init();
  Future<List<Expense>> getAll();
  Future<Expense> insert(Expense expense);
  Future<void> update(Expense expense);
  Future<void> delete(int id);
}

ExpenseStore createExpenseStore() => createStore();
