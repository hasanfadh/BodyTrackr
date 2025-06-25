import 'package:flutter/material.dart';
import 'package:body_trackr/utils/supabase_client.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final SupabaseClient _supabaseClient = SupabaseClient();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _supabaseClient.getUserProfileData();
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildProfileAvatar(),
      title: _buildUserName(),
      subtitle: _buildUserReasons(),
      trailing: const Icon(Icons.search),
    );
  }

  Widget _buildProfileAvatar() {
    if (_isLoading) {
      return const CircleAvatar(
        backgroundColor: Color(0xFFB0B0B0),
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final avatarUrl = _userData?['avatar_url'];

    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      child:
          avatarUrl == null
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
    );
  }

  Widget _buildUserName() {
    return _isLoading
        ? const Text(
          'Loading...',
          style: TextStyle(fontWeight: FontWeight.bold),
        )
        : Text(
          _userData?['name'] ?? 'Guest User',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
  }

  Widget _buildUserReasons() {
    return _isLoading
        ? const Text(
          "Loading...",
          style: TextStyle(fontWeight: FontWeight.bold),
        )
        : Text(
          _userData?['reasons']?.toString() ?? 'No reasons selected',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
  }
}
