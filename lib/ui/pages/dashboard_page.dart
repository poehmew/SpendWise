import 'package:flutter/material.dart';
import '../expenses_controller.dart';
import '../budget_controller.dart';
import '../widgets/expense_tile.dart';

class DashboardPage extends StatelessWidget {
  final ExpensesController expensesController;
  final BudgetController budgetController;

  const DashboardPage({
    super.key,
    required this.expensesController,
    required this.budgetController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([expensesController, budgetController]),
      builder: (context, _) {
        final all = expensesController.items;

        final totalSpent = all.fold<double>(0, (a, b) => a + b.amount);

        final bool hasBudget = budgetController.hasBudget;
        final double budget = budgetController.monthlyBudget ?? 0.0;

        final double ratio = (hasBudget && budget > 0) ? (totalSpent / budget) : 0.0;
        final double progress = ratio.clamp(0.0, 1.0);

        Color progressColor;
        if (!hasBudget || budget <= 0) {
          progressColor = Theme.of(context).colorScheme.primary;
        } else if (ratio < 0.7) {
          progressColor = Colors.green;
        } else if (ratio < 1.0) {
          progressColor = Colors.orange;
        } else {
          progressColor = Colors.red;
        }

        final recent = all.take(5).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            _card(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total spent', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '€${totalSpent.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _card(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Monthly budget', style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final v = await showBudgetDialog(
                            context,
                            initial: budgetController.monthlyBudget ?? 0.0,
                          );
                          if (v != null) await budgetController.setMonthlyBudget(v);
                        },
                        child: Text(hasBudget ? 'Edit' : 'Set'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  LinearProgressIndicator(
                    value: (hasBudget && budget > 0) ? progress : null,
                    minHeight: 12,
                    color: progressColor,
                    backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),

                  const SizedBox(height: 12),

                  if (!hasBudget || budget <= 0)
                    Text(
                      'Set a monthly budget to track progress.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                          ),
                    )
                  else if (totalSpent <= budget)
                    Text(
                      'Spent: €${totalSpent.toStringAsFixed(2)} / €${budget.toStringAsFixed(2)}\n'
                      'Remaining: €${(budget - totalSpent).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    Text(
                      'Spent: €${totalSpent.toStringAsFixed(2)} / €${budget.toStringAsFixed(2)}\n'
                      'Over budget by: €${(totalSpent - budget).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            Text('Recent transactions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),

            if (recent.isEmpty)
              _emptyState(context)
            else
              ...recent.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ExpenseTile(
                      expense: e,
                      onDelete: () {
                        final id = e.id;
                        if (id != null) expensesController.delete(id);
                      },
                    ),
                  )),
          ],
        );
      },
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _emptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: 52,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
          ),
          const SizedBox(height: 10),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to add your first expense.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }
}

/// Keep this only if your project doesn’t already have showBudgetDialog elsewhere.
Future<double?> showBudgetDialog(BuildContext context, {double? initial}) async {
  final controller = TextEditingController(
    text: initial != null && initial > 0 ? initial.toStringAsFixed(2) : '',
  );

  return showDialog<double>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Monthly budget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: 'e.g. 300'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(controller.text.trim());
              Navigator.pop(ctx, v);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
