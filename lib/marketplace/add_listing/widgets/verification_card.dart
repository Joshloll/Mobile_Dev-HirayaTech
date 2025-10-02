import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const VerificationCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.splineSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D3557),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}