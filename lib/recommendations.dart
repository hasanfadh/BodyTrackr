// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:body_trackr/recommendation_card.dart';
import 'package:flutter/material.dart';

class Recommendations extends StatelessWidget {
  const Recommendations({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rekomendasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'tampilkan semua',
                style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // scrollable area
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                // baris 1
                Row(
                  children: [
                    RecommendationCard(imagePath: 'assets/running.jpeg'),
                    const SizedBox(width: 24),
                    RecommendationCard(imagePath: 'assets/barbel.jpeg'),
                  ],
                ),
                const SizedBox(height: 12),
                // baris 2
                Row(
                  children: [
                    RecommendationCard(imagePath: 'assets/bike.jpeg'),
                    const SizedBox(width: 24),
                    RecommendationCard(imagePath: 'assets/calisthenics.jpg'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
