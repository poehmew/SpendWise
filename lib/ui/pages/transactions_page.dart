import 'package:flutter/material.dart';
import '../expenses_controller.dart';
import '../widgets/expense_tile.dart';

class TransactionsPage extends StatelessWidget {
  final ExpensesController expensesController;

  const TransactionsPage({
    super.key,
    required this.expensesController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: expensesController,
      builder: (context, _) {
        final items = expensesController.items;

        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No transactions yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first expense.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final e = items[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ExpenseTile(
                expense: e,
                onDelete: () {
                  final id = e.id;
                  if (id != null) expensesController.delete(id);
                },
              ),
            );
          },
        );
      },
    );
  }
}
