import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/marketplace/add_listing/add_listing_step1_page.dart';
import 'package:mobiledev_ecowaste/marketplace/add_listing/listing_form_provider.dart';
import 'package:provider/provider.dart';
import 'donation_journey_page.dart';

class DonatePage extends StatelessWidget {
  const DonatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> donatedItems = [
      {'name': 'iPhone 12 Pro', 'date': '15 May 2024', 'status': 'Redistributed'},
      {'name': 'MacBook Air M1', 'date': '22 Apr 2024', 'status': 'Awaiting'},
      {'name': 'Sony WH-1000XM4', 'date': '01 Mar 2024', 'status': 'Redistributed'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Previously Donated Items',
            style: GoogleFonts.splineSans(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...donatedItems.map((item) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DonationJourneyPage(item: item)),
                );
              },
              child: _buildDonationCard(item),
            );
          }).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (_) => ListingFormProvider(initialListingType: ListingType.donate),
                child: const AddListingStep1Page(),
              ),
            ),
          );
        },
        label: const Text('Donate a New Device'),
        icon: const Icon(Icons.add),
        // --- FIX: Removed hardcoded colors to use the global theme ---
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Redistributed': return Colors.blue.shade700;
      case 'Awaiting': return Colors.amber.shade700;
      default: return Colors.grey;
    }
  }

  Widget _buildDonationCard(Map<String, String> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text( item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), ),
                const SizedBox(height: 4),
                Text( 'Donated: ${item['date']!}', style: TextStyle(color: Colors.grey.shade600, fontSize: 14), ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text( 'Status', style: TextStyle(color: Colors.grey.shade600, fontSize: 14), ),
                const SizedBox(height: 4),
                Text(
                  item['status']!,
                  style: TextStyle(
                    color: _getStatusColor(item['status']!),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}