import 'package:flutter/material.dart';
import 'package:mobiledev_ecowaste/splash_screen.dart';
import 'package:mobiledev_ecowaste/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HirayaTech EcoWaste',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const SplashScreen(),
    );
  }
}