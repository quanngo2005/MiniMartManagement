import 'package:flutter/material.dart';

class CategorySummary {
  const CategorySummary({
    required this.name,
    required this.productCount,
    required this.icon,
    this.children = const [],
  });

  final String name;
  final int productCount;
  final IconData icon;
  final List<CategorySummary> children;

  int get subcategoryCount => children.length;
}
