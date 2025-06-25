// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';

class RecommendationCard extends StatelessWidget {
  final String imagePath;
  const RecommendationCard({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        imagePath,
        width: 150,
        height: 180,
        fit: BoxFit.cover,
      ), // **Perbesar ukuran gambar**
    );
  }
}
