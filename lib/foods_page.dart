// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:body_trackr/banana_page.dart';
import 'package:flutter/material.dart';

class FoodsPage extends StatelessWidget {
  const FoodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> imagePaths = [
      'assets/ayamMadu.jpg',
      'assets/steak.jpg',
      'assets/salmon.jpg',
      'assets/scrambledEgg.jpg',
      'assets/udang.jpg',
      'assets/tempeBacem.jpg',
      'assets/tahu.jpg',
      'assets/yogurt.jpg',
      'assets/telurRebus.jpg',
      'assets/pisang.jpg',
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Makanan',
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
                  _buildCategoryChip('Hewani'),
                  _buildCategoryChip('Nabati'),
                  _buildCategoryChip('Tinggi'),
                  _buildCategoryChip('Sedang'),
                  _buildCategoryChip('Rendah'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // GridView untuk menampilkan gambar makanan
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
                      // Cek apakah gambar ini adalah banana
                      if (imagePath.contains('pisang')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BananaPage(),
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
