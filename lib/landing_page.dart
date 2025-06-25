// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:body_trackr/goal_progress.dart';
import 'package:body_trackr/recommendations.dart';
import 'package:body_trackr/stats_grid.dart';
import 'package:body_trackr/user_profile.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30.0),
            const UserProfile(),
            const SizedBox(height: 10.0),
            const GoalProgress(),
            const SizedBox(height: 15.0),
            const StatsGrid(),
            const SizedBox(height: 10.0),
            const Recommendations(),
          ],
        ),
      ),
    );
  }
}
