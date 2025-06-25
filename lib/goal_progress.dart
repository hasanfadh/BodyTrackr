import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoalProgress extends StatefulWidget {
  const GoalProgress({super.key});

  @override
  GoalProgressState createState() => GoalProgressState();
}

class GoalProgressState extends State<GoalProgress> {
  Map<String, dynamic>? latestActivity;
  bool isLoading = true;
  String error = '';

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchLatestActivity();
  }

  Future<void> _fetchLatestActivity() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      final response =
          await supabase
              .from('sport_activities')
              .select()
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

      if (response != null) {
        setState(() {
          latestActivity = response;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load activity';
      });
      debugPrint('Error fetching activity: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C5945),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Baru saja',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              if (isLoading)
                const SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(color: Colors.white),
                )
              else if (error.isNotEmpty)
                Text(
                  error,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                )
              else if (latestActivity == null)
                const Text(
                  'Tidak ada aktivitas',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )
              else
                Text(
                  latestActivity!['activity_type'] ?? 'Aktivitas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
