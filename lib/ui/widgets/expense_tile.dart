import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../category_meta.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onDelete;

  const ExpenseTile({
    super.key,
    required this.expense,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final icon = CategoryMeta.iconFor(expense.category);
    final color = CategoryMeta.colorFor(expense.category);
    final label = CategoryMeta.labelFor(expense.category);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${expense.date} • $label',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '€${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFFE74C3C),
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ],
      ),
    );
  }
}
