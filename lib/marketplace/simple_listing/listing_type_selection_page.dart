// lib/marketplace/simple_listing/listing_type_selection_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mobiledev_ecowaste/marketplace/add_listing/listing_form_provider.dart';
import 'package:mobiledev_ecowaste/marketplace/add_listing/add_listing_step1_page.dart';

class ListingTypeSelectionPage extends StatelessWidget {
  const ListingTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List a Device'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How would you like to list your device?',
              style: GoogleFonts.splineSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D3557),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // DONATE Button
            _buildOptionCard(
              context,
              title: 'DONATE',
              description: 'Give your device to someone in need',
              icon: Icons.volunteer_activism,
              color: Colors.green,
              gradient: const LinearGradient(
                colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
              ),
              onTap: () => _navigateToCreateListing(context, 'donate'),
            ),
            const SizedBox(height: 20),
            
            // SELL Button
            _buildOptionCard(
              context,
              title: 'SELL',
              description: 'List your device for sale',
              icon: Icons.attach_money,
              color: const Color(0xFF3A86FF),
              gradient: const LinearGradient(
                colors: [Color(0xFF3A86FF), Color(0xFF5BA3FF)],
              ),
              onTap: () => _navigateToCreateListing(context, 'sell'),
            ),
            const SizedBox(height: 20),
            
            // TRADE Button
            _buildOptionCard(
              context,
              title: 'TRADE',
              description: 'Exchange your device for another',
              icon: Icons.swap_horiz,
              color: Colors.orange,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
              ),
              onTap: () => _navigateToCreateListing(context, 'trade'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.splineSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateListing(BuildContext context, String listingType) {
    final initialType = {
      'sell': ListingType.sell,
      'trade': ListingType.trade,
      'donate': ListingType.donate,
    }[listingType] ?? ListingType.sell;

    final provider = ListingFormProvider(initialListingType: initialType);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const AddListingStep1Page(),
        ),
      ),
    );
  }
}

