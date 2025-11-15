import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/history_repository.dart';
import 'onboarding_screen.dart';
import 'root_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Wait for the splash animation
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    final hasOnboarded = await HistoryRepository().getOnboarded();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            hasOnboarded ? const RootScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using a similar background to your HomePage for a smooth transition
      backgroundColor: const Color(0xFF232526),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your Lottie animation
            Lottie.asset(
              'assets/ideoo_g_icon.json',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              "GradeFlow",
              style: GoogleFonts.rampartOne(fontSize: 40, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
