import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/marketplace/add_listing/add_listing_step1_page.dart';
import 'package:mobiledev_ecowaste/marketplace/add_listing/listing_form_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';
import 'donation_journey_page.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({super.key});

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  final _supabaseService = SupabaseService();
  bool _isLoading = true;
  List<Map<String, String>> _donatedItems = [];

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() { _isLoading = true; });
    final userId = _supabaseService.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() { _isLoading = false; _donatedItems = []; });
      return;
    }

    final donations = await _supabaseService.getUserDonations(userId);

    final mapped = donations.map<Map<String, String>>((d) {
      final createdAtIso = d['created_at'] as String?;
      final createdAt = createdAtIso != null ? DateTime.tryParse(createdAtIso) : null;
      final formatted = createdAt != null
          ? '${createdAt.day.toString().padLeft(2, '0')} ${_month(createdAt.month)} ${createdAt.year}'
          : '';
      final statusRaw = (d['status'] as String?) ?? 'active';
      // Map backend status to user-friendly status labels
      final status = statusRaw == 'completed' ? 'Redistributed' : 'Awaiting';
      return {
        'name': (d['title'] as String?) ?? 'Donation',
        'date': formatted,
        'status': status,
      };
    }).toList();

    if (mounted) {
      setState(() { _donatedItems = mapped; _isLoading = false; });
    }
  }

  String _month(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[(m - 1).clamp(0, 11)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadDonations,
        child: ListView(
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
            if (_isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ))
            else if (_donatedItems.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('No donations yet', style: TextStyle(color: Colors.grey[600])),
                ),
              )
            else
              ..._donatedItems.map((item) {
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
          ).then((_) => _loadDonations());
        },
        label: const Text('Donate a New Device'),
        icon: const Icon(Icons.add),
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