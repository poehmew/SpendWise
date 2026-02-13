import 'package:flutter/material.dart';

class BarRow {
  final String label; // e.g. "02-10"
  final double value; // e.g. 45
  const BarRow(this.label, this.value);
}

class SimpleBarChart extends StatelessWidget {
  final List<BarRow> rows;

  const SimpleBarChart({
    super.key,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = rows.isEmpty
        ? 0.0
        : rows.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Column(
      children: rows.map((r) {
        final t = maxValue == 0 ? 0.0 : (r.value / maxValue).clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  r.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0, end: t),
                  builder: (context, v, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: v,
                        minHeight: 12,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withOpacity(0.55),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: Text(
                  '€${r.value.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
