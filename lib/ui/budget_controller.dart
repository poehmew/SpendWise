import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetController extends ChangeNotifier {
  static const _key = 'monthly_budget';
  double? _monthlyBudget;

  double? get monthlyBudget => _monthlyBudget;
  bool get hasBudget => _monthlyBudget != null && _monthlyBudget! > 0;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _monthlyBudget = prefs.getDouble(_key);
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double value) async {
    _monthlyBudget = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, value);
  }

  Future<void> clearBudget() async {
    _monthlyBudget = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
