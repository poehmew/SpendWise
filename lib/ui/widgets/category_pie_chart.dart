import 'dart:math';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatelessWidget {
  /// Keep both names to avoid “named parameter” errors if your page uses `data:` or `values:`
  final Map<String, double>? data;
  final Map<String, double>? values;

  final String? centerText;
  final double strokeWidth;

  const CategoryPieChart({
    super.key,
    this.data,
    this.values,
    this.centerText,
    this.strokeWidth = 26,
  });

  Map<String, double> get _map => data ?? values ?? const {};

  @override
  Widget build(BuildContext context) {
    final map = _map;

    final total = map.values.fold<double>(0, (a, b) => a + b);
    final theme = Theme.of(context);

    if (map.isEmpty || total <= 0) {
      return Container(
        height: 260,
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Text(
          'No data yet',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.55),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // ✅ Fix cut issue: give enough space & keep it square
    return SizedBox(
      height: 260,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) {
          return AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _PiePainter(
                map: map,
                progress: t,
                strokeWidth: strokeWidth,
                bgColor: theme.colorScheme.surface,
                textColor: theme.colorScheme.onSurface,
                centerText: centerText,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  final Map<String, double> map;
  final double progress; // 0..1 animation progress
  final double strokeWidth;
  final Color bgColor;
  final Color textColor;
  final String? centerText;

  _PiePainter({
    required this.map,
    required this.progress,
    required this.strokeWidth,
    required this.bgColor,
    required this.textColor,
    this.centerText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = map.values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - strokeWidth / 2;

    // background ring
    final bgPaint = Paint()
      ..color = textColor.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // draw slices
    double start = -pi / 2;

    final entries = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    for (final e in entries) {
      final sweepFull = (e.value / total) * 2 * pi;
      final sweep = sweepFull * progress; // animate sweep
      final paint = Paint()
        ..color = _colorForCategory(e.key) // ✅ Transport color improved here
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );

      start += sweepFull;
    }

    // center label
    final label = centerText ?? '€${total.toStringAsFixed(0)}';
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$label\nTotal',
        style: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          height: 1.25,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.8);

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) {
    return oldDelegate.map != map ||
        oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.centerText != centerText;
  }
}

/// ✅ Improvement #2 (Transport blue looks nicer and consistent)
Color _colorForCategory(String category) {
  final c = category.toLowerCase();
  if (c.contains('food')) return Colors.orange.shade600;
  if (c.contains('transport')) return Colors.blue.shade600; // improved transport
  if (c.contains('shopping')) return Colors.purple.shade600;
  return Colors.grey.shade600; // other
}
