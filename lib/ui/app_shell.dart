import 'package:flutter/material.dart';

import '../models/expense.dart';
import 'budget_controller.dart';
import 'expenses_controller.dart';
import 'theme_controller.dart';

import 'pages/dashboard_page.dart';
import 'pages/transactions_page.dart';
import 'pages/stats_page.dart';
import 'pages/profile_page.dart';

import 'widgets/add_expense_dialog.dart';

class AppShell extends StatefulWidget {
  final ExpensesController expensesController;
  final ThemeController themeController;
  final BudgetController budgetController;

  const AppShell({
    super.key,
    required this.expensesController,
    required this.themeController,
    required this.budgetController,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  Future<void> _addExpense() async {
    final Expense? created = await showAddExpenseDialog(context);
    if (created != null) {
      await widget.expensesController.insert(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardPage(
        expensesController: widget.expensesController,
        budgetController: widget.budgetController,
      ),
      TransactionsPage(expensesController: widget.expensesController),
      StatsPage(
        expensesController: widget.expensesController,
        budgetController: widget.budgetController,
      ),
      ProfilePage(
        themeController: widget.themeController,
        budgetController: widget.budgetController,
      ),
    ];

    return Scaffold(
      body: pages[_index],
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
