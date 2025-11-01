// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:mobiledev_ecowaste/auth/sign_in_page.dart'; // We point this to your existing sign-in page

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This screen will simply display the beautiful sign-in page you already built
    return const SignInPage();
  }
}
