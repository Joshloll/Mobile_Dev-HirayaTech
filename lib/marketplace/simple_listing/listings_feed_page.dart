// lib/marketplace/simple_listing/listings_feed_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';
import 'package:intl/intl.dart';
import 'listing_details_page.dart';

class ListingsFeedPage extends StatefulWidget {
  const ListingsFeedPage({super.key});

  @override
  State<ListingsFeedPage> createState() => _ListingsFeedPageState();
}

class _ListingsFeedPageState extends State<ListingsFeedPage> {
  final _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _listings = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'sell', 'trade', 'donate'

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() { _isLoading = true; });

    List<Map<String, dynamic>> listings;
    if (_selectedFilter == 'all') {
      listings = await _supabaseService.getAllListings();
    } else {
      listings = await _supabaseService.getListingsByType(_selectedFilter);
    }

    if (mounted) {
      setState(() {
        _listings = listings;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter chips
        _buildFilterChips(),
        
        // Listings grid/list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _listings.isEmpty
                  ? _buildEmptyState()
                  : _buildListingsGrid(),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('For Sale', 'sell'),
            const SizedBox(width: 8),
            _buildFilterChip('For Trade', 'trade'),
            const SizedBox(width: 8),
            _buildFilterChip('For Donation', 'donate'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = value;
          });
          _loadListings();
        }
      },
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildListingsGrid() {
    return RefreshIndicator(
      onRefresh: _loadListings,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _listings.length,
        itemBuilder: (context, index) {
          return _buildListingCard(_listings[index]);
        },
      ),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> listing) {
    final imageUrls = listing['image_urls'] as List<dynamic>?;
    final firstImage = (imageUrls != null && imageUrls.isNotEmpty) 
        ? imageUrls[0] as String 
        : null;

    final listingType = listing['listing_type'] as String;
    final price = listing['price'];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailsPage(listing: listing),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: firstImage != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          firstImage,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.devices, size: 50, color: Colors.grey),
                      ),
              ),
            ),
            
            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getTypeColor(listingType),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        listingType.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Title
                    Text(
                      listing['title'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.splineSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    
                    // Price or info
                    if (listingType == 'sell' && price != null)
                      Text(
                        '₱${NumberFormat("#,###").format(price)}',
                        style: const TextStyle(
                          color: Color(0xFF3A86FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    else if (listingType == 'donate')
                      const Text(
                        'Free',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      const Text(
                        'Trade',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No listings yet',
            style: GoogleFonts.splineSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to list a device!',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'sell':
        return const Color(0xFF3A86FF);
      case 'trade':
        return Colors.orange;
      case 'donate':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

