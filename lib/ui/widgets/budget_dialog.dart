import 'package:flutter/material.dart';

Future<double?> showBudgetDialog(BuildContext context, {double initial = 0}) {
  final controller = TextEditingController(
    text: initial > 0 ? initial.toStringAsFixed(2) : '',
  );

  return showDialog<double?>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Monthly budget'),
      content: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Budget (€)',
          hintText: 'e.g. 300',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final v = double.tryParse(controller.text.replaceAll(',', '.'));
            if (v == null || v <= 0) {
              Navigator.pop(context, 0);
              return;
            }
            Navigator.pop(context, v);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
