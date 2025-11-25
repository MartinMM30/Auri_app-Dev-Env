import 'package:flutter/material.dart';
import 'package:auri_app/widgets/auri_visual.dart';
import 'package:auri_app/routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 200, height: 200, child: AuriVisual()),
            const SizedBox(height: 30),
            const Text(
              'AURI ASISTENTE',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tu asistente de vida personal y estilo.',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 18,
                ),
                elevation: 5,
              ),
              child: const Text(
                'Empezar mi día',
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.surveyInitial,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
