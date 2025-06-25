// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:body_trackr/utils/supabase_client.dart';

class ConditionForm extends StatefulWidget {
  const ConditionForm({super.key});

  @override
  State<ConditionForm> createState() => _ConditionFormState();
}

class _ConditionFormState extends State<ConditionForm> {
  final _caloriesController = TextEditingController();
  final _stepsController = TextEditingController();
  final _proteinController = TextEditingController();
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

  Future<void> _submitData() async {
    try {
      final calories = int.tryParse(_caloriesController.text) ?? 0;
      final steps = int.tryParse(_stepsController.text) ?? 0;
      final protein = int.tryParse(_proteinController.text) ?? 0;

      await _supabaseClient.saveDailyStats(
        calories: calories,
        steps: steps,
        protein: protein,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      _userData?['avatar_url'] != null
                          ? NetworkImage(_userData!['avatar_url'])
                          : null,
                  child:
                      _userData?['avatar_url'] == null
                          ? const Icon(Icons.account_circle, size: 40)
                          : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLoading
                            ? "Loading..."
                            : _userData?['name'] ?? 'Guest User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _isLoading
                            ? "Loading..."
                            : _userData?['reasons'] ?? 'No reasons selected',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Bagaimana kondisimu hari ini?",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildTextField("Kalori terbakar hari ini", _caloriesController),
            _buildTextField("Langkah kaki hari ini", _stepsController),
            _buildTextField("Protein makanan hari ini", _proteinController),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submitData, child: const Text("Submit")),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _stepsController.dispose();
    _proteinController.dispose();
    super.dispose();
  }
}
