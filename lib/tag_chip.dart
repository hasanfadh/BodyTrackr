// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String label;

  const TagChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label), backgroundColor: Colors.grey.shade200);
  }
}
