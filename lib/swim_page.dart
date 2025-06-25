// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:body_trackr/main_screen.dart';
import 'package:body_trackr/timer_page.dart';
import 'package:body_trackr/tag_chip.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SwimPage extends StatefulWidget {
  const SwimPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SwimPageState createState() => _SwimPageState();
}

class _SwimPageState extends State<SwimPage> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _durationController = TextEditingController(
    text: '60',
  );
  double caloriesBurned = 700;

  Future<void> _saveActivity() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final duration = int.tryParse(_durationController.text) ?? 0;

      await _supabase.from('sport_activities').insert({
        'user_id': userId,
        'activity_type': 'swim', // Identifier unik
        'duration': duration,
        'calories': caloriesBurned,
        'start_time': DateTime.now().toIso8601String(),
        'status': 'ongoing',
        'custom_data': {
          'pool_length': 25, // Contoh data spesifik renang
          'style': 'freestyle',
        },
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => TimerPage(
                  duration: duration,
                  activityId: DateTime.now().millisecondsSinceEpoch.toString(),
                ),
          ),
        );
      }
    } catch (e) {
      // Error handling
    }
  }

  void _calculateCalories() {
    int duration = int.tryParse(_durationController.text) ?? 0;
    // Asumsikan 700 kalori per 60 menit = 11.67 kalori/menit
    setState(() {
      caloriesBurned = duration * (700 / 60);
    });
  }

  @override
  void initState() {
    super.initState();
    _calculateCalories();
    _durationController.addListener(_calculateCalories);
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Olahraga'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MainScreen(initialIndex: 1),
              ),
            );
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar utama
            Container(
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/swim.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Informasi renang
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Renang',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        TagChip(label: 'Cardio'),
                        TagChip(label: 'Balance & Coordination'),
                        TagChip(label: 'BodyWeight'),
                        TagChip(label: 'Strength'),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Input durasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Durasi olahraga anda: ',
                        style: TextStyle(fontSize: 16),
                      ),
                      Container(
                        width: 60,
                        height: 35,
                        margin: EdgeInsets.only(left: 8),
                        child: TextField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('menit'),
                    ],
                  ),

                  SizedBox(height: 10),
                  Text(
                    'Bakar ${caloriesBurned.toStringAsFixed(0)} kilo kalori',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),

                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveActivity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2C5F3E),
                      padding: EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Mulai',
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
