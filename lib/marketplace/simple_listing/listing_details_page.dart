// lib/marketplace/simple_listing/listing_details_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';
import 'package:mobiledev_ecowaste/marketplace/messaging/chat_page.dart';
import 'package:intl/intl.dart';
import 'package:mobiledev_ecowaste/profile/public_profile_page.dart';
import 'package:mobiledev_ecowaste/marketplace/trade/select_partner_listing_page.dart';
import 'package:mobiledev_ecowaste/marketplace/transactions_page.dart';

class ListingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> listing;

  const ListingDetailsPage({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: SupabaseService().getListingById(listing['id'] as String),
      builder: (context, snapshot) {
        final listing = {
          ...this.listing,
          if (snapshot.data != null) ...snapshot.data!,
        };

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
        final isPending = (listing['status'] as String?) == 'pending'; // kept for compatibility, but we don't rely on it now

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
                        _buildImageCarousel(
                          imageUrls,
                          heroTag: listing['id'] ?? (imageUrls.isNotEmpty ? imageUrls.first : null),
                        )
                      else
                        Hero(
                          tag: listing['id'] ?? 'placeholder-${listing['title']}',
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.devices, size: 100, color: Colors.grey),
                              ),
                            ),
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
                                  Flexible(
                                    child: Text(
                                      '₱${NumberFormat("#,###").format(price)}',
                                      textAlign: TextAlign.end,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontFamily: 'Roboto', // Peso sign support
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3A86FF),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Title
                            Text(
                              listing['title'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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

                            // Specifications
                            _sectionTitle('Device Information'),
                            const SizedBox(height: 8),
                            _detailRow('Device Type', (listing['device_type'] ?? listing['deviceType'] ?? 'N/A').toString()),
                            _detailRow('Brand', (listing['brand'] ?? 'N/A').toString()),
                            _detailRow('Model', (listing['model'] ?? 'N/A').toString()),
                            _detailRow('Storage', (listing['storage'] ?? listing['storage_capacity'] ?? 'N/A').toString()),
                            _detailRow('Color', (listing['color'] ?? 'N/A').toString()),
                            const SizedBox(height: 16),

                            // Inclusions & History
                            _sectionTitle("What's Included"),
                            const SizedBox(height: 8),
                            _detailRow(
                              'Accessories',
                              (() {
                                final acc = listing['accessories'];
                                if (acc is List) return acc.isEmpty ? 'None' : List<String>.from(acc).join(', ');
                                return (acc?.toString().isNotEmpty == true) ? acc.toString() : 'None';
                              })(),
                            ),
                            _detailRow('Repair History', (listing['repairHistory'] ?? 'None').toString()),
                            const SizedBox(height: 16),

                            // Condition Summary
                            _sectionTitle('Condition Summary'),
                            const SizedBox(height: 8),
                            ..._buildConditions(listing),
                            const SizedBox(height: 16),

                            // Verification Proofs
                            _sectionTitle('Verification Proofs'),
                            const SizedBox(height: 8),
                            ..._buildProofs(context, listing),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom action button(s)
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (listingType == 'sell') ...[
                          ElevatedButton(
                            onPressed: () => _requestBuy(context),
                            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                            child: const Text('Buy Now'),
                          ),
                          const SizedBox(height: 8),
                        ]
                        else if (listingType == 'trade') ...[
                          ElevatedButton(
                            onPressed: () => _proposeTrade(context),
                            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                            child: const Text('Propose Trade'),
                          ),
                          const SizedBox(height: 8),
                        ]
                        else if (listingType == 'donate') ...[
                          ElevatedButton(
                            onPressed: () => _requestDonation(context),
                            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                            child: const Text('Request Donation'),
                          ),
                          const SizedBox(height: 8),
                        ],
                        OutlinedButton.icon(
                          onPressed: () => _contactSeller(context, userId),
                          icon: const Icon(Icons.message),
                          label: const Text('Message Seller'),
                          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                        ),
                      ],
                    ),
                  ),
                ),
              if (isOwnListing)
                FutureBuilder<Map<String, dynamic>?>(
                  future: SupabaseService().getPendingTransactionForListing(listing['id'] as String),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }

                    final hasPending = snapshot.data != null;
                    return hasPending ? _buildOwnerPendingActions(context, listingType) : const SizedBox.shrink();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.splineSans(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text('$title:', style: TextStyle(color: Colors.grey[700]))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConditions(Map<String, dynamic> listing) {
    final verification = listing['verification'] as Map<String, dynamic>? ?? {};
    String fmt(bool? v) => (v ?? false) ? 'Yes' : 'No';
    return [
      _detailRow('Powers on correctly?', fmt(verification['powersOn'] as bool?)),
      _detailRow('Buttons functional?', fmt(verification['buttonsFunctional'] as bool?)),
      _detailRow('Battery drains fast?', fmt(verification['batteryDrainsFast'] as bool?)),
      _detailRow('Screen has damage?', fmt(verification['screenDamage'] as bool?)),
      _detailRow('Touchscreen responsive?', fmt(verification['touchResponsive'] as bool?)),
    ];
  }

  List<Widget> _buildProofs(BuildContext context, Map<String, dynamic> listing) {
    final verification = listing['verification'] as Map<String, dynamic>? ?? {};
    final batteryPhotoUrl = verification['batteryPhotoUrl'] ?? listing['batteryPhotoUrl'] ?? verification['battery_photo_url'] ?? listing['battery_photo_url'];
    final screenDamagePhotoUrl = verification['screenDamagePhotoUrl'] ?? listing['screenDamagePhotoUrl'] ?? verification['screen_damage_photo_url'] ?? listing['screen_damage_photo_url'];
    final functionalityVideoUrl = verification['functionalityVideoUrl'] ?? listing['functionalityVideoUrl'] ?? verification['functionality_video_url'] ?? listing['functionality_video_url'];
    final powersOnVideoUrl = verification['powersOnVideoUrl'] ?? listing['powersOnVideoUrl'] ?? verification['powers_on_video_url'] ?? listing['powers_on_video_url'];
    final buttonsVideoUrl = verification['buttonsVideoUrl'] ?? listing['buttonsVideoUrl'] ?? verification['buttons_video_url'] ?? listing['buttons_video_url'];
    final touchscreenVideoUrl = verification['touchscreenVideoUrl'] ?? listing['touchscreenVideoUrl'] ?? verification['touchscreen_video_url'] ?? listing['touchscreen_video_url'];

    final widgets = <Widget>[];
    void addPhoto(String label, dynamic url) {
      if (url is String && url.isNotEmpty) {
        widgets.addAll([
          Text(label, style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 180, color: Colors.grey[200], alignment: Alignment.center, child: const Icon(Icons.image_not_supported)),
            ),
          ),
          const SizedBox(height: 12),
        ]);
      }
    }
    void addVideo(String label, dynamic url) {
      if (url is String && url.isNotEmpty) {
        widgets.add(
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.videocam_outlined),
            title: Text(label),
            subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: TextButton(
              onPressed: () => _openLink(context, url),
              child: const Text('Open'),
            ),
          ),
        );
      }
    }

    addPhoto('Battery Photo', batteryPhotoUrl);
    addPhoto('Screen Damage Photo', screenDamagePhotoUrl);
    addVideo('Functionality Video', functionalityVideoUrl);
    addVideo('Powers On Video', powersOnVideoUrl);
    addVideo('Buttons Functional Video', buttonsVideoUrl);
    addVideo('Touchscreen Responsive Video', touchscreenVideoUrl);

    if (widgets.isEmpty) {
      widgets.add(Text('No verification proofs provided.', style: TextStyle(color: Colors.grey[600])));
    }
    return widgets;
  }

  void _openLink(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Open Link'),
        content: SelectableText(url),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<dynamic> imageUrls, {Object? heroTag}) {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final img = Image.network(
            imageUrls[index] as String,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 100, color: Colors.grey),
              );
            },
          );
          if (index == 0 && heroTag != null) {
            return Hero(tag: heroTag, child: img);
          }
          return img;
        },
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, String userName, String? userAvatar, String userId, bool isOwn) {
    return InkWell(
      onTap: () {
        if (!isOwn) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfilePage(userId: userId)));
        }
      },
      child: Container(
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

  Widget _buildOwnerPendingActions(BuildContext context, String listingType) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _ownerCancel(context, listingType),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _ownerConfirm(context, listingType),
                child: const Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _ownerConfirm(BuildContext context, String listingType) async {
    final service = SupabaseService();
    final listingId = listing['id'] as String;
    final tx = await service.getPendingTransactionForListing(listingId);
    if (tx == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No pending transaction found')));
      }
      return;
    }
    String? err;
    if (listingType == 'sell') err = await service.confirmSale(tx['id'] as String);
    else if (listingType == 'trade') err = await service.confirmTrade(tx['id'] as String);
    else if (listingType == 'donate') err = await service.confirmDonation(tx['id'] as String);

    if (context.mounted) {
      if (err == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text('Transaction confirmed.')));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text('Error: $err')));
      }
    }
  }

  Future<void> _ownerCancel(BuildContext context, String listingType) async {
    final service = SupabaseService();
    final listingId = listing['id'] as String;
    final tx = await service.getPendingTransactionForListing(listingId);
    if (tx == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No pending transaction found')));
      }
      return;
    }
    final err = await service.cancelTransaction(tx['id'] as String);

    if (context.mounted) {
      if (err == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction cancelled.')));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text('Error: $err')));
      }
    }
  }

  Future<void> _requestBuy(BuildContext context) async {
    final service = SupabaseService();
    final res = await service.requestBuy(listing['id'] as String);
    if (context.mounted) {
      if (res != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text('Purchase requested. Waiting for seller confirmation.')));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text('Failed to request purchase')));
      }
    }
  }

  Future<void> _proposeTrade(BuildContext context) async {
    final partnerId = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => SelectPartnerListingPage()),
    );
    if (partnerId == null) return;
    final service = SupabaseService();
    final res = await service.proposeTrade(listingId: listing['id'] as String, partnerListingId: partnerId);
    if (!context.mounted) return;
    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text('Trade proposed. Waiting for seller confirmation.')));
      // Return to Marketplace (previous page) instead of routing to Transactions
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text('Failed to propose trade')));
    }
  }

  Future<void> _requestDonation(BuildContext context) async {
    final service = SupabaseService();
    final res = await service.requestDonation(listing['id'] as String);
    if (context.mounted) {
      if (res != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text('Donation requested. Waiting for donor confirmation.')));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text('Failed to request donation')));
      }
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

