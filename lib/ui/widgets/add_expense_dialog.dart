import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../category_meta.dart';

Future<Expense?> showAddExpenseDialog(
  BuildContext context, {
  Expense? initial,
}) {
  return showDialog<Expense?>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _AddExpenseDialog(initial: initial),
  );
}

class _AddExpenseDialog extends StatefulWidget {
  final Expense? initial;
  const _AddExpenseDialog({this.initial});

  @override
  State<_AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<_AddExpenseDialog> {
  late final TextEditingController _title;
  late final TextEditingController _amount;

  late DateTime _date;
  late String _category;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _title = TextEditingController(text: i?.title ?? '');
    _amount = TextEditingController(text: i == null ? '' : i.amount.toStringAsFixed(2));
    _date = i == null ? DateTime.now() : DateTime.parse(i.date);
    _category = i?.category ?? CategoryMeta.other;
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final title = _title.text.trim();
    final amount = double.tryParse(_amount.text.replaceAll(',', '.'));

    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a title and valid amount.")),
      );
      return;
    }

    final result = Expense(
      id: widget.initial?.id,
      title: title,
      amount: amount,
      date: _fmt(_date),       // ✅ date is String
      category: _category,
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: 18 + MediaQuery.of(context).viewInsets.bottom, // ✅ keyboard safe
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(isEdit ? "Edit expense" : "Add expense",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Amount (€)"),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(_fmt(_date)),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _category,
              items: CategoryMeta.all
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(CategoryMeta.iconFor(c), size: 18),
                            const SizedBox(width: 8),
                            Text(c),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? CategoryMeta.other),
              decoration: const InputDecoration(labelText: "Category"),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(isEdit ? "Save" : "Add"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
