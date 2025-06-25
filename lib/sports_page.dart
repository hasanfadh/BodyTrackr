// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:body_trackr/swim_page.dart';
import 'package:flutter/material.dart';

class SportsPage extends StatelessWidget {
  const SportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> imagePaths = [
      'assets/barbel.jpeg',
      'assets/bike.jpeg',
      'assets/calisthenics.jpg',
      'assets/jumpRope.jpg',
      'assets/pushUp.jpg',
      'assets/running.jpeg',
      'assets/soccer.jpeg',
      'assets/swim.jpg',
      'assets/taiChi.jpg',
      'assets/yoga.jpg',
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Paket Olahraga',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('Semua'),
                  _buildCategoryChip('Cardio'),
                  _buildCategoryChip('Bodyweight'),
                  _buildCategoryChip('Strength'),
                  _buildCategoryChip('Flexibility'),
                  _buildCategoryChip('Coordination'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // GridView untuk menampilkan gambar olahraga
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  String imagePath = imagePaths[index];
                  return GestureDetector(
                    onTap: () {
                      // Cek apakah gambar ini adalah renang
                      if (imagePath.contains('swim')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SwimPage(),
                          ),
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(imagePath, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[300],
      ),
    );
  }
}
