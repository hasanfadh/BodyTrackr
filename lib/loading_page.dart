// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:body_trackr/_create_route.dart';
import 'package:body_trackr/welcome_page.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, createRoute(WelcomePage()));
      },
      child: Scaffold(
        backgroundColor: Color(0xFF2C5945),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logoPutih.png', width: 150, height: 150),
            ],
          ),
        ),
      ),
    );
  }
}
