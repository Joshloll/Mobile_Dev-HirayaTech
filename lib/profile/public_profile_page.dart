// lib/profile/public_profile_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';
import 'package:mobiledev_ecowaste/marketplace/messaging/chat_page.dart';
import 'package:intl/intl.dart';

class PublicProfilePage extends StatefulWidget {
  final String userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  final _supabaseService = SupabaseService();
  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; });

    final profile = await _supabaseService.getUserProfile(widget.userId);
    final transactions = await _supabaseService.getUserTransactions(widget.userId);

    if (mounted) {
      setState(() {
        _userProfile = profile;
        _transactions = transactions;
        _isLoading = false;
      });
    }
  }

  Future<void> _startConversation() async {
    final conversationId = await _supabaseService.getOrCreateConversation(widget.userId);

    if (conversationId != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            conversationId: conversationId,
            otherUserId: widget.userId,
            otherUserName: _userProfile?['name'] ?? 'User',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_userProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Unable to load profile')),
      );
    }

    final isOwnProfile = _supabaseService.currentUser?.id == widget.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _userProfile!['avatar_url'] != null
                        ? NetworkImage(_userProfile!['avatar_url'] as String)
                        : null,
                    child: _userProfile!['avatar_url'] == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userProfile!['name'] as String,
                    style: GoogleFonts.splineSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userProfile!['email'] as String,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Member since ${DateTime.parse(_userProfile!['created_at'] as String).year}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (!isOwnProfile) ...[
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _startConversation,
                      icon: const Icon(Icons.message),
                      label: const Text('Message'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

            // Transactions section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transactions (${_transactions.length})',
                    style: GoogleFonts.splineSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_transactions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        return _buildTransactionCard(_transactions[index]);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final listingType = transaction['listing_type'] as String;
    final title = transaction['title'] as String;
    final status = transaction['status'] as String;
    final price = transaction['price'];
    final imageUrl = transaction['first_image_url'] as String?;
    final createdAt = transaction['created_at'] != null
        ? DateTime.parse(transaction['created_at'] as String)
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.devices),
                    );
                  },
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.devices),
              ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (listingType == 'sell' && price != null)
              Text(
                '₱${NumberFormat("#,###").format(price)}',
                style: const TextStyle(
                  color: Color(0xFF3A86FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (createdAt != null)
              Text(
                _formatDate(createdAt),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'sold':
      case 'traded':
      case 'donated':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }
}

