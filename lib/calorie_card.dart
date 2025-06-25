import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CalorieCard extends StatelessWidget {
  final int calories;
  final int targetCalories;
  final bool isLoading;

  const CalorieCard({
    super.key,
    required this.calories,
    this.targetCalories = 4500,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        targetCalories > 0 ? (calories / targetCalories).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.black54),
              SizedBox(width: 6),
              Text(
                'Kalori Terbakar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child:
                  isLoading
                      ? const CircularProgressIndicator()
                      : CircularPercentIndicator(
                        radius: 60.0,
                        lineWidth: 10.0,
                        percent: progress,
                        center: Text(
                          '${_formatNumber(calories)}\nkcal',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        progressColor: _getProgressColor(progress),
                        backgroundColor: Colors.grey.shade300,
                      ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Target Harian ${_formatNumber(targetCalories)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }
}
