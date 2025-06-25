import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _activityData = [];
  bool _isLoading = true;
  late RealtimeChannel _sportChannel;

  @override
  void initState() {
    super.initState();
    _testDatabaseConnection();
    _initRealtimeSubscription();
    _fetchActivityData();
  }

  @override
  void dispose() {
    _sportChannel.unsubscribe();
    super.dispose();
  }

  void _initRealtimeSubscription() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _sportChannel = _supabase.channel('sport_updates_$userId');

    final subscription = _sportChannel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'sport_activities',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        debugPrint('Realtime update: ${payload.toString()}');
        if (mounted) {
          _fetchActivityData();
        }
      },
    );

    subscription.subscribe((error, [_]) {
      debugPrint('Subscription error: $error');
    });
  }

  Future<void> _fetchActivityData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Ambil data olahraga dan makanan sekaligus
      final sportData = await _supabase
          .from('sport_activities')
          .select()
          .eq('user_id', userId)
          .order('start_time', ascending: false)
          .limit(15);

      final foodData = await _supabase
          .from('food_logs')
          .select()
          .eq('user_id', userId)
          .order('logged_at', ascending: false)
          .limit(15);

      // Debug print untuk memverifikasi data
      debugPrint('Data olahraga dari DB: ${sportData.toString()}');
      debugPrint('Data makanan dari DB: ${foodData.toString()}');

      _formatCombinedData(sportData, foodData);
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // PERBAIKAN UTAMA: Logika pengelompokan tanggal yang lebih akurat
  // SOLUSI SEDERHANA: Ganti method _formatCombinedData dengan ini

  void _formatCombinedData(List<dynamic> sportData, List<dynamic> foodData) {
    final Map<String, Map<String, dynamic>> combinedData = {};

    debugPrint('=== DEBUGGING RAW DATA ===');
    debugPrint('Sport data: ${sportData.length} items');
    debugPrint('Food data: ${foodData.length} items');

    // Proses data olahraga
    for (var activity in sportData) {
      try {
        final utcDate = DateTime.parse(activity['start_time']);
        final localDate = utcDate.toLocal();
        final normalizedDate = DateTime(
          localDate.year,
          localDate.month,
          localDate.day,
        );
        final dateKey = _getDateKey(normalizedDate);

        combinedData.putIfAbsent(
          dateKey,
          () => {'olahraga': [], 'makanan': [], 'kalori': 0.0, 'protein': 0.0},
        );

        combinedData[dateKey]!['olahraga'].add(activity);
        combinedData[dateKey]!['kalori'] +=
            (activity['calories'] ?? 0).toDouble();

        debugPrint('Sport: ${activity['start_time']} -> $dateKey');
      } catch (e) {
        debugPrint('Error processing sport: $e');
      }
    }

    // Proses data makanan - MODIFIKASI: Maju 1 hari
    for (var food in foodData) {
      try {
        final utcDate = DateTime.parse(food['logged_at']);
        final localDate = utcDate.toLocal();
        final normalizedDate = DateTime(
          localDate.year,
          localDate.month,
          localDate.day,
        );
        // MODIFIKASI: Tambah 1 hari untuk data makanan
        final adjustedDate = normalizedDate.add(const Duration(days: 1));
        final dateKey = _getDateKey(adjustedDate);

        combinedData.putIfAbsent(
          dateKey,
          () => {'olahraga': [], 'makanan': [], 'kalori': 0.0, 'protein': 0.0},
        );

        combinedData[dateKey]!['makanan'].add(food);
        combinedData[dateKey]!['kalori'] += (food['energy'] ?? 0).toDouble();
        combinedData[dateKey]!['protein'] += (food['protein'] ?? 0).toDouble();

        debugPrint('Food: ${food['logged_at']} -> $dateKey (maju 1 hari)');
      } catch (e) {
        debugPrint('Error processing food: $e');
      }
    }

    // Debug semua data yang sudah dikelompokkan
    debugPrint('=== GROUPED DATA ===');
    combinedData.forEach((key, value) {
      debugPrint(
        '$key: Sport=${value['olahraga'].length}, Food=${value['makanan'].length}',
      );
    });

    // SOLUSI TIMEZONE: Ambil tanggal terbaru dari data sebagai "hari ini"
    final allDates = combinedData.keys.toList()..sort((a, b) => b.compareTo(a));

    if (allDates.isEmpty) {
      // Jika tidak ada data, gunakan system date
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      setState(() {
        _activityData = [
          _createDayData('Hari ini', today, combinedData),
          _createDayData(
            'Kemarin',
            today.subtract(const Duration(days: 1)),
            combinedData,
          ),
          _createDayData(
            '2 hari yang lalu',
            today.subtract(const Duration(days: 2)),
            combinedData,
          ),
        ];
      });
      return;
    }

    // Ambil 3 tanggal terbaru dan beri label yang tepat
    final latestDate = DateTime.parse(allDates[0]);
    final secondDate =
        allDates.length > 1
            ? DateTime.parse(allDates[1])
            : latestDate.subtract(const Duration(days: 1));
    final thirdDate =
        allDates.length > 2
            ? DateTime.parse(allDates[2])
            : latestDate.subtract(const Duration(days: 2));

    debugPrint('=== FINAL DATES ===');
    debugPrint('Latest (Hari ini): ${_getDateKey(latestDate)}');
    debugPrint('Second (Kemarin): ${_getDateKey(secondDate)}');
    debugPrint('Third (2 hari lalu): ${_getDateKey(thirdDate)}');

    setState(() {
      _activityData = [
        _createDayData('Hari ini', latestDate, combinedData),
        _createDayData('Kemarin', secondDate, combinedData),
        _createDayData('2 hari yang lalu', thirdDate, combinedData),
      ];
    });
  }

  Map<String, dynamic> _createDayData(
    String title,
    DateTime date,
    Map<String, Map<String, dynamic>> sourceData,
  ) {
    final dateKey = _getDateKey(date);
    final dayData =
        sourceData[dateKey] ??
        {'olahraga': [], 'makanan': [], 'kalori': 0.0, 'protein': 0.0};

    debugPrint('Creating day data for $title ($dateKey):');
    debugPrint('  Found ${dayData['olahraga'].length} olahraga activities');
    debugPrint('  Found ${dayData['makanan'].length} makanan logs');

    final exerciseImages = _getExerciseImages(dayData['olahraga']);
    final foodImages = _getFoodImages(dayData['makanan']);

    return {
      'title': title,
      'entries': [
        {
          'kalori': dayData['kalori'].toStringAsFixed(0),
          'langkah': '950',
          'protein': dayData['protein'].toStringAsFixed(1),
        },
        {'kalori': '', 'langkah': '', 'protein': ''},
      ],
      'olahraga': exerciseImages,
      'makanan': foodImages,
    };
  }

  String _getDateKey(DateTime date) {
    // Pastikan date sudah dalam bentuk normalized (tanpa waktu)
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return DateFormat('yyyy-MM-dd').format(normalizedDate);
  }

  List<String> _getExerciseImages(List<dynamic> activities) {
    const exerciseImages = {
      'swim': 'assets/swim.jpg',
      'swimming': 'assets/swim.jpg',
      'run': 'assets/jumpRope.jpg',
      'running': 'assets/jumpRope.jpg',
      'cycle': 'assets/bike.jpeg',
      'cycling': 'assets/bike.jpeg',
      'yoga': 'assets/yoga.jpg',
      'weight': 'assets/barbel.jpeg',
      'weightlifting': 'assets/barbel.jpeg',
    };

    debugPrint('Getting exercise images for ${activities.length} activities');

    return activities.take(2).map<String>((activity) {
      final activityType =
          activity['activity_type']?.toString().toLowerCase() ?? '';
      final imagePath =
          exerciseImages[activityType] ?? 'assets/default_exercise.jpg';

      debugPrint('Activity type: $activityType -> Image: $imagePath');
      return imagePath;
    }).toList();
  }

  Future<void> _testDatabaseConnection() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      debugPrint('Current user ID: $userId');

      if (userId == null) {
        debugPrint('ERROR: User not authenticated');
        return;
      }

      // Test query sederhana
      final testQuery = await _supabase
          .from('sport_activities')
          .select('id, activity_type, start_time')
          .eq('user_id', userId)
          .limit(5);

      debugPrint('Test query result: $testQuery');

      if (testQuery.isEmpty) {
        debugPrint('WARNING: No sport activities found for user $userId');
      } else {
        debugPrint('SUCCESS: Found ${testQuery.length} activities');
      }
    } catch (e) {
      debugPrint('ERROR testing database: $e');
    }
  }

  List<String> _getFoodImages(List<dynamic> foods) {
    const foodImages = {
      'Pisang': 'assets/pisang.jpg',
      'Steak': 'assets/steak.jpg',
      'Telur Rebus': 'assets/telurRebus.jpg',
      'Ayam Madu': 'assets/ayamMadu.jpg',
      'Yogurt': 'assets/yogurt.jpg',
      'Salmon': 'assets/salmon.jpg',
    };

    return foods
        .take(2)
        .map((f) => foodImages[f['food_name']] ?? 'assets/default_food.jpg')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Aktivitas Anda',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchActivityData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: _activityData.map(_buildActivitySection).toList(),
                  ),
                ),
              ),
    );
  }

  Widget _buildActivitySection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data['title'],
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ringkasan Hari Ini:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(data['entries'].length, (index) {
                  final entry = data['entries'][index];
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '#${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildConditionRow('Kalori', entry['kalori']),
                          _buildConditionRow('Langkah', entry['langkah']),
                          _buildConditionRow('Protein', entry['protein']),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bagian olahraga
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Olahraga:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              data['olahraga'].isEmpty
                                  ? [const Text('Tidak ada olahraga')]
                                  : List.generate(
                                    data['olahraga'].length,
                                    (index) => _buildImageCard(
                                      data['olahraga'][index],
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Bagian makanan
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Makanan:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              data['makanan'].isEmpty
                                  ? [const Text('Tidak ada makanan')]
                                  : List.generate(
                                    data['makanan'].length,
                                    (index) =>
                                        _buildImageCard(data['makanan'][index]),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildConditionRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        const Text(' : ', style: TextStyle(color: Colors.white)),
        Text(
          value.isNotEmpty ? value : '-',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildImageCard(String assetPath) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(image: AssetImage(assetPath), fit: BoxFit.cover),
      ),
    );
  }
}
