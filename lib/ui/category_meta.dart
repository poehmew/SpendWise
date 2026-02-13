import 'package:flutter/material.dart';

class CategoryMeta {
  // ✅ What your existing files expect:
  static const List<String> all = <String>[
    'Food',
    'Transport',
    'Shopping',
    'Other',
  ];

  static const String other = 'Other';

  // ✅ Icons
  static IconData iconFor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  // ✅ Fixed A+ colors
  static Color colorFor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color(0xFFF59E0B); // orange
      case 'transport':
        return const Color(0xFF3B82F6); // blue
      case 'shopping':
        return const Color(0xFF8B5CF6); // purple
      default:
        return const Color(0xFF64748B); // slate
    }
  }

  // Optional (handy for UI)
  static String labelFor(String category) {
    // keep original casing if already good
    for (final c in all) {
      if (c.toLowerCase() == category.toLowerCase()) return c;
    }
    return 'Other';
  }
}
