import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: unused_import
import 'package:body_trackr/utils/supabase_client.dart';
import 'package:body_trackr/stats_card.dart';
import 'package:body_trackr/calorie_card.dart';

class StatsGrid extends StatefulWidget {
  const StatsGrid({super.key});

  @override
  State<StatsGrid> createState() => _StatsGridState();
}

class _StatsGridState extends State<StatsGrid> {
  final _supabase = Supabase.instance.client;
  int _steps = 0;
  int _protein = 0;
  int _calories = 0;
  bool _isLoading = true;
  RealtimeChannel? _subscription;

  @override
  void initState() {
    super.initState();
    _loadTodayStats();
    _setupRealtimeSubscription();
  }

  Future<void> _loadTodayStats() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response =
          await _supabase
              .rpc(
                'get_daily_totals',
                params: {
                  'userid': user.id,
                  'start_date': startOfDay.toIso8601String(),
                  'end_date': endOfDay.toIso8601String(),
                },
              )
              .single();

      setState(() {
        _steps = response['total_steps'] ?? 0;
        _protein = response['total_protein'] ?? 0;
        _calories = response['total_calories'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading daily totals: $e');
    }
  }

  void _setupRealtimeSubscription() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _subscription =
        _supabase
            .channel('daily_stats_updates')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'daily_conditions',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: user.id,
              ),
              callback: (_) => _loadTodayStats(),
            )
            .subscribe();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _loadTodayStats();
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.63,
          crossAxisSpacing: 5,
          mainAxisSpacing: 10,
        ),
        children: [
          CalorieCard(
            calories: _calories,
            targetCalories: 4500, // Bisa disesuaikan atau diambil dari database
            isLoading: _isLoading,
          ),
          Column(
            children: [
              StatsCard(
                title: 'Langkah Kaki',
                value: _isLoading ? '...' : _formatNumber(_steps),
                unit: 'langkah',
                bgColor: const Color(0xFFE0E0E0),
                icon: Icons.directions_walk,
              ),
              const SizedBox(height: 6),
              StatsCard(
                title: 'Protein',
                value: _isLoading ? '...' : '$_protein',
                unit: 'gram',
                bgColor: const Color(0xFFDFF5E4),
                icon: Icons.restaurant,
              ),
            ],
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
}
