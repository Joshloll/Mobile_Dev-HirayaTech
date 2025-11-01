// lib/marketplace/simple_listing/listing_details_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';
import 'package:mobiledev_ecowaste/marketplace/messaging/chat_page.dart';
import 'package:intl/intl.dart';

class ListingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> listing;

  const ListingDetailsPage({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final imageUrls = listing['image_urls'] as List<dynamic>?;
    final listingType = listing['listing_type'] as String;
    final price = listing['price'];
    final userId = listing['user_id'] as String;
    final userName = listing['user_name'] as String? ?? 'Unknown User';
    final userAvatar = listing['user_avatar_url'] as String?;
    final createdAt = listing['created_at'] != null
        ? DateTime.parse(listing['created_at'] as String)
        : null;

    final currentUser = SupabaseService().currentUser;
    final isOwnListing = currentUser?.id == userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Images carousel
                  if (imageUrls != null && imageUrls.isNotEmpty)
                    _buildImageCarousel(imageUrls)
                  else
                    Container(
                      height: 300,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.devices, size: 100, color: Colors.grey),
                      ),
                    ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type badge and price
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getTypeColor(listingType),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                listingType.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (listingType == 'sell' && price != null)
                              Text(
                                '₱${NumberFormat("#,###").format(price)}',
                                style: GoogleFonts.splineSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF3A86FF),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          listing['title'] as String,
                          style: GoogleFonts.splineSans(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Date
                        if (createdAt != null)
                          Text(
                            'Posted ${_formatDate(createdAt)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        const SizedBox(height: 16),

                        // User info
                        _buildUserInfo(context, userName, userAvatar, userId, isOwnListing),
                        const SizedBox(height: 24),

                        // Description
                        Text(
                          'Description',
                          style: GoogleFonts.splineSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          listing['description'] as String? ?? 'No description',
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 24),

                        // Trade details if applicable
                        if (listingType == 'trade' && listing['trade_details'] != null) ...[
                          Text(
                            'Looking For',
                            style: GoogleFonts.splineSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            listing['trade_details'] as String,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom action button
          if (!isOwnListing)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton.icon(
                  onPressed: () => _contactSeller(context, userId),
                  icon: const Icon(Icons.message),
                  label: const Text('Message Seller'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<dynamic> imageUrls) {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Image.network(
            imageUrls[index] as String,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 100, color: Colors.grey),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, String userName, String? userAvatar, String userId, bool isOwn) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: userAvatar != null ? NetworkImage(userAvatar) : null,
            child: userAvatar == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.splineSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  isOwn ? 'Your listing' : 'Seller',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _contactSeller(BuildContext context, String sellerId) async {
    final supabaseService = SupabaseService();
    final conversationId = await supabaseService.getOrCreateConversation(
      sellerId,
      listingId: listing['id'] as String?,
    );

    if (conversationId != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            conversationId: conversationId,
            otherUserId: sellerId,
            otherUserName: listing['user_name'] as String? ?? 'Unknown User',
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
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

