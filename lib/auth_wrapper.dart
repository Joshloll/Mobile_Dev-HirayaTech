// lib/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobiledev_ecowaste/screens/home_screen.dart';
import 'package:mobiledev_ecowaste/screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data?.session != null) {
          // If user is logged in, show home screen
          return const HomeScreen();
        } else {
          // If user is not logged in, show login screen
          return const LoginScreen();
        }
      },
    );
  }
}
