// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool allNotificationsPaused = false;

  String conditionReminder = 'Nonaktif';
  String workoutReminder = 'Nonaktif';
  String foodReminder = 'Nonaktif';
  String motivation = 'Nonaktif';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kelola notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Notifikasi otomatis'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Jeda semua', style: TextStyle(fontSize: 18)),
              Switch(
                value: allNotificationsPaused,
                onChanged: (val) {
                  setState(() {
                    allNotificationsPaused = val;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildOptionGroup(
            title: 'Pengingat untuk perbarui kondisi',
            value: conditionReminder,
            onChanged: (val) {
              setState(() {
                conditionReminder = val!;
              });
            },
            activeNote: 'Anda belum update kondisi hari ini!',
          ),
          _buildOptionGroup(
            title: 'Pengingat olahraga',
            value: workoutReminder,
            onChanged: (val) {
              setState(() {
                workoutReminder = val!;
              });
            },
            activeNote: 'Lanjutkan olahraga mu! 🔥',
          ),
          _buildOptionGroup(
            title: 'Pengingat makan',
            value: foodReminder,
            onChanged: (val) {
              setState(() {
                foodReminder = val!;
              });
            },
            activeNote: 'Lanjutkan pola makan sehat-mu! 🔥',
          ),
          _buildOptionGroup(
            title: 'Motivasi',
            value: motivation,
            onChanged: (val) {
              setState(() {
                motivation = val!;
              });
            },
            activeNote:
                '"I don’t stop when I’m tired. I stop when I’m done"– David Goggins',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOptionGroup({
    required String title,
    required String value,
    required ValueChanged<String?> onChanged,
    required String activeNote,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        RadioListTile<String>(
          title: const Text('Nonaktif'),
          value: 'Nonaktif',
          groupValue: value,
          onChanged: onChanged,
        ),
        RadioListTile<String>(
          title: const Text('Aktif'),
          value: 'Aktif',
          groupValue: value,
          onChanged: onChanged,
        ),
        if (value == 'Aktif')
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            child: Text(
              activeNote,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
      ],
    );
  }
}
