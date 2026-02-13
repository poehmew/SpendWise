import 'package:flutter/material.dart';
import '../budget_controller.dart';
import '../theme_controller.dart';

class ProfilePage extends StatelessWidget {
  final ThemeController themeController;
  final BudgetController budgetController;

  const ProfilePage({
    super.key,
    required this.themeController,
    required this.budgetController,
  });

  Future<double?> _showBudgetDialog(BuildContext context, {double? initial}) async {
    final ctrl = TextEditingController(text: initial == null ? '' : initial.toStringAsFixed(0));
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set monthly budget'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Budget (€)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return null;
    final v = double.tryParse(ctrl.text.replaceAll(',', '.'));
    if (v == null || v <= 0) return null;
    return v;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([budgetController, themeController]),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: const [
                      Icon(Icons.account_balance_wallet_rounded, size: 52),
                      SizedBox(height: 10),
                      Text('SpendWise', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                      SizedBox(height: 6),
                      Text('Personal finance tracker', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 0,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark mode'),
                      subtitle: const Text('Toggle light/dark theme'),
                      value: themeController.themeMode == ThemeMode.dark,
                      onChanged: (v) => themeController.setMode(v ? ThemeMode.dark : ThemeMode.light),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.flag_rounded),
                      title: const Text('Monthly budget'),
                      subtitle: Text(
                        budgetController.hasBudget
                            ? '€${budgetController.monthlyBudget!.toStringAsFixed(2)}'
                            : 'Not set',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final v = await _showBudgetDialog(context, initial: budgetController.monthlyBudget);
                        if (v != null) await budgetController.setMonthlyBudget(v);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Clear budget'),
                      enabled: budgetController.hasBudget,
                      onTap: budgetController.hasBudget ? () => budgetController.clearBudget() : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Card(
                elevation: 0,
                child: Column(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.badge_outlined),
                      title: Text('Authors'),
                      subtitle: Text('Poe Eint Hmew (100002753)'),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.link),
                      title: Text('Course'),
                      subtitle: Text('Operating Systems/Web Computing-Group 1'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
