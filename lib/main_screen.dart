// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:body_trackr/condition_form.dart';
import 'package:body_trackr/foods_page.dart';
import 'package:body_trackr/landing_page.dart';
import 'package:body_trackr/profile_page.dart';
import 'package:body_trackr/sports_page.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Index default adalah LandingPage

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _pages = const [
    LandingPage(),
    SportsPage(),
    FoodsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Fungsi untuk menampilkan ConditionForm saat logo diklik
  void _showConditionForm() {
    showDialog(
      context: context,
      barrierDismissible: true, // Klik luar untuk menutup
      builder: (BuildContext context) {
        return ConditionForm();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [IndexedStack(index: _selectedIndex, children: _pages)],
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  /// Widget Custom BottomNavBar
  Widget _buildCustomBottomNavBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.directions_run, 1),
          _buildLogoButton(), // Logo button akan memanggil form
          _buildNavItem(Icons.restaurant, 2),
          _buildNavItem(Icons.person, 3),
        ],
      ),
    );
  }

  /// Widget untuk tombol navigasi
  Widget _buildNavItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Icon(
        icon,
        size: 30,
        color: _selectedIndex == index ? const Color(0xFF2C5945) : Colors.grey,
      ),
    );
  }

  /// Widget untuk logo di tengah navbar
  Widget _buildLogoButton() {
    return GestureDetector(
      onTap: _showConditionForm, // Klik logo akan menampilkan ConditionForm
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Image.asset('assets/logoNoName.png', width: 50, height: 50),
      ),
    );
  }
}
