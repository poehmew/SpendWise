import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../budget_controller.dart';
import '../expenses_controller.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/simple_bar_chart.dart';
import '../category_meta.dart';

class StatsPage extends StatefulWidget {
  final ExpensesController expensesController;
  final BudgetController budgetController;

  const StatsPage({
    super.key,
    required this.expensesController,
    required this.budgetController,
  });

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  List<Expense> _inMonth(List<Expense> all) {
    return all.where((e) {
      try {
        final d = DateTime.parse(e.date);
        return d.year == _month.year && d.month == _month.month;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Map<String, double> _byCategory(List<Expense> items) {
    final map = <String, double>{};

    for (final c in CategoryMeta.all) {
      map[c] = 0;
    }

    for (final e in items) {
      final key = CategoryMeta.labelFor(e.category);
      map[key] = (map[key] ?? 0) + e.amount;
    }

    return map;
  }

  List<BarRow> _last7Days(List<Expense> items) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final map = <String, double>{};

    for (final d in days) {
      final key = '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      map[key] = 0;
    }

    for (final e in items) {
      DateTime? dt;
      try {
        dt = DateTime.parse(e.date);
      } catch (_) {
        continue;
      }
      final key = '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      if (map.containsKey(key)) map[key] = (map[key] ?? 0) + e.amount;
    }

    return map.entries.map((e) => BarRow(e.key, e.value)).toList();
  }

  String _monthLabel(DateTime m) {
    const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${names[m.month - 1]} ${m.year}';
  }

  Future<void> _pickMonth() async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) => _MonthPickerDialog(initial: _month),
    );
    if (picked != null) setState(() => _month = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.expensesController,
      builder: (context, _) {
        final all = widget.expensesController.items;
        final items = _inMonth(all);

        final total = items.fold<double>(0, (a, b) => a + b.amount);
        final byCat = _byCategory(items);
        final bars = _last7Days(items);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Stats'),
            actions: [
              TextButton.icon(
                onPressed: _pickMonth,
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(_monthLabel(_month)),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.query_stats_rounded, size: 44),
                          const SizedBox(height: 12),
                          Text(
                            'No data for ${_monthLabel(_month)}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                          const SizedBox(height: 6),
                          const Text('Add expenses to see stats.'),
                        ],
                      ),
                    )
                  : ListView(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Spending by category',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                              const SizedBox(height: 14),
                              CategoryPieChart(
                                data: byCat,
                                centerText: '€${total.toStringAsFixed(0)}',
                              ),
                              const SizedBox(height: 14),
                              ...CategoryMeta.all.map((c) {
                                final v = byCat[c] ?? 0;
                                final pct = total == 0 ? 0 : (v / total) * 100;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Icon(CategoryMeta.iconFor(c), color: CategoryMeta.colorFor(c)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '$c (${pct.toStringAsFixed(0)}%)',
                                          style: const TextStyle(fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                      Text(
                                        '€${v.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.w900),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Last 7 days',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              SimpleBarChart(rows: bars),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _MonthPickerDialog extends StatefulWidget {
  final DateTime initial;
  const _MonthPickerDialog({required this.initial});

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int year;
  late int month;

  @override
  void initState() {
    super.initState();
    year = widget.initial.year;
    month = widget.initial.month;
  }

  @override
  Widget build(BuildContext context) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Select month', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () => setState(() => year--), icon: const Icon(Icons.chevron_left_rounded)),
                Text('$year', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                IconButton(onPressed: () => setState(() => year++), icon: const Icon(Icons.chevron_right_rounded)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(12, (i) {
                final m = i + 1;
                final selected = m == month;
                return SizedBox(
                  width: 80,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => month = m),
                    icon: selected ? const Icon(Icons.check_rounded, size: 18) : const SizedBox.shrink(),
                    label: Text(months[i]),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: selected ? const Color(0xFFDEE5FF) : null,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: () => Navigator.pop(context, DateTime(year, month)),
                  child: const Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
