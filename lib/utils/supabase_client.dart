import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class SupabaseClient {
  static final SupabaseClient _instance = SupabaseClient._internal();
  static SupabaseClient get instance => _instance;
  factory SupabaseClient() => _instance;
  SupabaseClient._internal();

  final _supabase = Supabase.instance.client;

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String gender,
    required int age,
    required int height,
    required int weight,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _supabase.from('profiles').upsert({
      'id': user.id,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'id');
  }

  Future<void> saveDailyStats({
    required int calories,
    required int steps,
    required int protein,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _supabase.from('daily_conditions').insert({
      'user_id': user.id,
      'date': DateTime.now().toIso8601String(),
      'calories': calories,
      'steps': steps,
      'protein': protein,
    });
  }

  Future<void> saveUserReasons(List<String> reasons) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _supabase.from('user_reasons').upsert({
      'user_id': user.id,
      'reasons': reasons,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response =
          await _supabase
              .from('user_profile_with_reasons')
              .select()
              .eq('id', user.id)
              .single();

      return {
        'name': response['full_name'],
        'reasons': response['formatted_reasons'],
      };
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getUserProfileData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final response =
        await _supabase
            .from('profiles')
            .select(
              'first_name, last_name, gender, age, height, weight, created_at, avatar_url',
            )
            .eq('id', user.id)
            .single();

    final reasonsResponse =
        await _supabase
            .from('user_reasons')
            .select('reasons')
            .eq('user_id', user.id)
            .maybeSingle();

    return {
      'name': '${response['first_name']} ${response['last_name']}',
      'reasons':
          reasonsResponse?['reasons']?.join(', ') ?? 'Belum memilih alasan',
      'gender': response['gender'] ?? 'Belum diisi',
      'age': response['age']?.toString() ?? '0',
      'height': response['height']?.toString() ?? '0',
      'weight': response['weight']?.toString() ?? '0',
      'created_at': DateTime.parse(response['created_at']).year.toString(),
      'avatar_url': response['avatar_url'],
    };
  }

  Future<void> uploadProfileImage(XFile image) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final bytes = await image.readAsBytes();
    final fileExt = image.path.split('.').last;
    final fileName = '${user.id}.$fileExt';
    final filePath = 'profile_images/$fileName';

    await _supabase.storage
        .from('avatars')
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(contentType: image.mimeType, upsert: true),
        );

    final imageUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);

    await _supabase
        .from('profiles')
        .update({'avatar_url': imageUrl})
        .eq('id', user.id);
  }
}
