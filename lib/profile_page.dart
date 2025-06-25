import 'dart:async';
import 'package:body_trackr/activity_page.dart';
import 'package:body_trackr/edit_profile_page.dart';
import 'package:body_trackr/login_page.dart';
import 'package:body_trackr/notification_page.dart';
import 'package:body_trackr/reset_password_page.dart';
import 'package:body_trackr/utils/supabase_client.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_pkg;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _supabaseClient = SupabaseClient();
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() => _isLoading = true);
        await _supabaseClient.uploadProfileImage(pickedFile);
        await _loadUserData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diperbarui')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengupload foto: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _isLoading
                      ? const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.black12,
                        child: CircularProgressIndicator(),
                      )
                      : CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.black12,
                        backgroundImage:
                            _userData?['avatar_url'] != null
                                ? NetworkImage(_userData!['avatar_url'])
                                : null,
                        child:
                            _userData?['avatar_url'] == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                      ),
                  GestureDetector(
                    onTap: () => _showUploadDialog(context),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade900,
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                    children: [
                      Text(
                        _userData?['name'] ?? 'Nama Pengguna',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userData?['reasons'] ?? 'Belum memilih alasan',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_userData?['gender'] ?? 'Gender'} | ${_userData?['age'] ?? '0'} tahun | ${_userData?['height'] ?? '0'} cm | ${_userData?['weight'] ?? '0'} kg',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
              const SizedBox(height: 32),

              _buildMenuItem(
                context,
                Icons.edit,
                'Edit profil',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                ).then((value) {
                  if (value == true) {
                    _loadUserData();
                  }
                }),
              ),
              _buildMenuItem(
                context,
                Icons.access_time,
                'Aktivitas Anda',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ActivityPage()),
                ),
              ),
              _buildMenuItem(
                context,
                Icons.notifications,
                'Kelola notifikasi',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(),
                  ),
                ),
              ),
              _buildMenuItem(
                context,
                Icons.lock,
                'Reset kata sandi',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResetPasswordPage(),
                  ),
                ),
              ),

              const Spacer(),
              Text(
                'bergabung dari ${_userData?['created_at'] ?? '2024'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  await supabase_pkg.Supabase.instance.client.auth.signOut();
                  if (mounted) {
                    Navigator.pushReplacement(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade900,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Keluar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unggah Foto Profil'),
          content: const Text('Pilih sumber foto'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
              child: const Text('Kamera'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
              child: const Text('Galeri'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green.shade900,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(indent: 72, height: 1),
      ],
    );
  }
}
