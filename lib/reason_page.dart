// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:body_trackr/_create_route.dart';
import 'package:body_trackr/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:body_trackr/utils/supabase_client.dart';

class ReasonPage extends StatefulWidget {
  const ReasonPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReasonPageState createState() => _ReasonPageState();
}

class _ReasonPageState extends State<ReasonPage> {
  final _supabaseClient = SupabaseClient();
  bool _isLoading = false;
  final List<String> reasons = [
    "Kesehatan",
    "Kompetisi",
    "Stres",
    "Kebugaran",
    "Body Goals",
    "Produktivitas",
  ];
  List<String> selectedReasons = [];

  void _toggleSelection(String reason) {
    setState(() {
      if (selectedReasons.contains(reason)) {
        selectedReasons.remove(reason);
      } else if (selectedReasons.length < 3) {
        selectedReasons.add(reason);
      }
    });
  }

  Future<void> _saveAndContinue() async {
    if (selectedReasons.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _supabaseClient.saveUserReasons(selectedReasons);
      if (mounted) {
        Navigator.push(context, createRoute(MainScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan alasan: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                const Text(
                  'Kenali dirimu!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Apa alasan utamamu untuk bergabung BodyTrackr?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),

                /// Pilihan alasan dalam bentuk kotak
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children:
                      reasons.map((reason) {
                        bool isSelected = selectedReasons.contains(reason);
                        return GestureDetector(
                          onTap: () => _toggleSelection(reason),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color(0xFF2C5945)
                                      : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              reason,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),

                const SizedBox(height: 15),
                const Text(
                  "*pilih maksimal 3 alasan",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),

                const SizedBox(height: 70),

                /// Tombol Continue
                ElevatedButton(
                  onPressed: selectedReasons.isEmpty ? null : _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedReasons.isEmpty
                            ? Colors.grey
                            : const Color(0xFF2C5945),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 50,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Continue',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
