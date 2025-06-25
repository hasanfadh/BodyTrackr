// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:body_trackr/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://aodzwkfpxnbrddeunuuy.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvZHp3a2ZweG5icmRkZXVudXV5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY0MTk3MzMsImV4cCI6MjA2MTk5NTczM30.qE9DK1m5w9RmJsG9GyAvoqAvUcIzSOrSHbL03zNgk0Q ',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoadingPage());
  }
}
