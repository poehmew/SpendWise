import 'package:flutter/material.dart';

import 'data/expense_store.dart';
import 'ui/app_shell.dart';
import 'ui/budget_controller.dart';
import 'ui/expenses_controller.dart';
import 'ui/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = createExpenseStore();
  final expensesController = ExpensesController(store);
  final themeController = ThemeController();
  final budgetController = BudgetController();

  await expensesController.init();
  await themeController.init();
  await budgetController.init();

  runApp(SpendWiseApp(
    expensesController: expensesController,
    themeController: themeController,
    budgetController: budgetController,
  ));
}

class SpendWiseApp extends StatelessWidget {
  final ExpensesController expensesController;
  final ThemeController themeController;
  final BudgetController budgetController;

  const SpendWiseApp({
    super.key,
    required this.expensesController,
    required this.themeController,
    required this.budgetController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SpendWise',
          themeMode: themeController.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          ),
          darkTheme: ThemeData.dark(useMaterial3: true),
          home: AppShell(
            expensesController: expensesController,
            themeController: themeController,
            budgetController: budgetController,
          ),
        );
      },
    );
  }
}
