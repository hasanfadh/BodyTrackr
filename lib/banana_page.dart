// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BananaPage extends StatefulWidget {
  const BananaPage({super.key});

  @override
  _BananaPageState createState() => _BananaPageState();
}

class _BananaPageState extends State<BananaPage> {
  final TextEditingController _amountController = TextEditingController(
    text: '100',
  );
  final _supabase = Supabase.instance.client;

  // Data nutrisi per 100g
  static const Map<String, double> _nutritionData = {
    'energy': 89,
    'protein': 1.1,
    'fat': 0.3,
    'carbs': 22.8,
  };

  Map<String, double> _calculatedNutrition = {
    'energy': 89,
    'protein': 1.1,
    'fat': 0.3,
    'carbs': 22.8,
  };

  void _calculateNutrition() {
    final amount = int.tryParse(_amountController.text) ?? 0;
    setState(() {
      _calculatedNutrition = _nutritionData.map(
        (key, value) => MapEntry(key, (amount / 100) * value),
      );
    });
  }

  Widget tagChip(String label, Color color) {
    return Chip(label: Text(label), backgroundColor: color);
  }

  Future<void> _logFood() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('food_logs').insert({
        'user_id': userId,
        'food_name': 'Pisang',
        'amount': int.tryParse(_amountController.text) ?? 100,
        'energy': _calculatedNutrition['energy'],
        'protein': _calculatedNutrition['protein'],
        'fat': _calculatedNutrition['fat'],
        'carbs': _calculatedNutrition['carbs'],
        'meal_type': 'snack', // Bisa dibuat selectable
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pisang berhasil dicatat!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
        Navigator.pop(context, true); // Kembali dengan refresh data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mencatat: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _calculateNutrition();
    _amountController.addListener(_calculateNutrition);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pisang'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: 300,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/pisang.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Pisang',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      tagChip('Protein Nabati', Colors.green),
                      tagChip('Protein Rendah', Colors.yellow),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Banyak makanan: ',
                        style: TextStyle(fontSize: 16),
                      ),
                      Container(
                        width: 60,
                        height: 35,
                        margin: const EdgeInsets.only(left: 8),
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('gram'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Komposisi Gizi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Energi      : ${_calculatedNutrition['energy']!.toStringAsFixed(0)} kkal',
                      ),
                      Text(
                        'Protein     : ${_calculatedNutrition['protein']!.toStringAsFixed(1)} gram',
                      ),
                      Text(
                        'Lemak       : ${_calculatedNutrition['fat']!.toStringAsFixed(1)} gram',
                      ),
                      Text(
                        'Karbohidrat : ${_calculatedNutrition['carbs']!.toStringAsFixed(1)} gram',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _logFood,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Masukkan',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
