// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:mobiledev_ecowaste/marketplace/marketplace_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Show the main marketplace page with bottom navigation
    return const MarketplacePage();
  }
}
