import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobiledev_ecowaste/auth_wrapper.dart';
import 'package:mobiledev_ecowaste/theme.dart';

void main() async {
  // Ensure Flutter is ready before we use plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    runApp(const _ConfigErrorApp());
    return;
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

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

class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Configuration Required')),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: SelectableText(
            'Missing Supabase configuration.\n\n'
            'Please run the app with:\n'
            'flutter run --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY',
          ),
        ),
      ),
    );
  }
}