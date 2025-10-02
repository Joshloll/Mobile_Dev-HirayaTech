import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobiledev_ecowaste/auth/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// --- MODIFIED: Added 'with SingleTickerProviderStateMixin' for animations ---
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  // --- NEW: Animation controller and animation variables ---
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Setup the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Create a curved animation for a more natural feel
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Start the animation
    _controller.forward();

    // The timer for navigating to the login page remains the same
    Timer(const Duration(seconds: 3), _navigateToLogin);
  }

  @override
  void dispose() {
    // --- NEW: Dispose the controller to free up resources ---
    _controller.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // --- MODIFIED: Wrapped the Image in animation widgets ---
        child: ScaleTransition(
          scale: _animation,
          child: FadeTransition(
            opacity: _animation,
            child: Image.asset(
              'assets/images/HirayaTech.png',
              // Increased size slightly as requested
              width: 250,
            ),
          ),
        ),
      ),
    );
  }
}