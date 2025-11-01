import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobiledev_ecowaste/auth_wrapper.dart';
import 'package:mobiledev_ecowaste/theme.dart';

void main() async {
  // Ensure Flutter is ready before we use plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://kdbctvolqjmhboikhutx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtkYmN0dm9scWptaGJvaWtodXR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwMDg0NjcsImV4cCI6MjA3NzU4NDQ2N30.ATovG2lM9ArDQAOfcxPbxmzbpAuzHsg7DzK8UG7gHY4',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoWaste',
      theme: appTheme, // UPDATE: Using the appTheme variable from your theme.dart file
      home: const AuthWrapper(), // The AuthWrapper will handle what screen to show
    );
  }
}