// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _supabase = Supabase.instance.client;
  final List<String> _allReasons = [
    'Kesehatan',
    'Kompetisi',
    'Stres',
    'Kebugaran',
    'Body Goals',
    'Produktivitas',
  ];
  List<String> _selectedReasons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserReasons();
  }

  // Di dalam class _EditProfilePageState (edit_profile_page.dart)

  Future<void> _updateProfile() async {
    try {
      setState(() => _isLoading = true);
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Konversi nilai ke integer
      final height = int.tryParse(_heightController.text) ?? 0;
      final weight = int.tryParse(_weightController.text) ?? 0;

      // Update profile data
      final profileResponse =
          await _supabase
              .from('profiles')
              .upsert({
                'id': userId,
                'first_name': _firstNameController.text.trim(),
                'last_name': _lastNameController.text.trim(),
                'gender': _genderController.text.trim(),
                'age': int.tryParse(_ageController.text) ?? 0,
                'height': height,
                'weight': weight,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      debugPrint('Profile updated: $profileResponse');

      // Update reasons
      final reasonsResponse =
          await _supabase
              .from('user_reasons')
              .upsert({
                'user_id': userId,
                'reasons': _selectedReasons.toList(),
                'updated_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      debugPrint('Reasons updated: $reasonsResponse');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadUserReasons() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Load profile data
      final profileResponse =
          await _supabase.from('profiles').select().eq('id', userId).single();

      // Load reasons
      final reasonsResponse =
          await _supabase
              .from('user_reasons')
              .select()
              .eq('user_id', userId)
              .maybeSingle();

      setState(() {
        _firstNameController.text = profileResponse['first_name'] ?? '';
        _lastNameController.text = profileResponse['last_name'] ?? '';
        _genderController.text = profileResponse['gender'] ?? '';
        _ageController.text = profileResponse['age']?.toString() ?? '';
        _heightController.text = profileResponse['height']?.toString() ?? '';
        _weightController.text = profileResponse['weight']?.toString() ?? '';
        _selectedReasons = List<String>.from(reasonsResponse?['reasons'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: ${e.toString()}')),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'), // Ubah judul
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tambahkan form input di sini
                    _buildTextField('Nama Depan', _firstNameController),
                    const SizedBox(height: 16),
                    _buildTextField('Nama Belakang', _lastNameController),
                    const SizedBox(height: 16),
                    _buildTextField('Jenis Kelamin', _genderController),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberField('Umur', _ageController),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildNumberField(
                            'Tinggi (cm)',
                            _heightController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildNumberField(
                            'Berat (kg)',
                            _weightController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Alasan Bergabung:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _allReasons.map((reason) {
                            final isSelected = _selectedReasons.contains(
                              reason,
                            );
                            return ChoiceChip(
                              label: Text(reason),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    if (_selectedReasons.length < 3) {
                                      _selectedReasons.add(reason);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Maksimal 3 alasan!'),
                                        ),
                                      );
                                    }
                                  } else {
                                    _selectedReasons.remove(reason);
                                  }
                                });
                              },
                              selectedColor: Colors.green.shade900,
                              backgroundColor: Colors.grey[200],
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.grey[800],
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed:
                            _updateProfile, // Gunakan _updateProfile bukan _updateReasons
                        child: const Text('Simpan Profil'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
