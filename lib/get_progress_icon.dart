// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';

IconData getProgressIcon(String title) {
  switch (title) {
    case 'Kalori Terbakar':
      return Icons.local_fire_department;
    case 'Langkah Kaki':
      return Icons.directions_walk;
    case 'Protein':
      return Icons.fastfood;
    default:
      return Icons.insert_chart;
  }
}
