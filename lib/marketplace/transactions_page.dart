import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';
import 'package:mobiledev_ecowaste/marketplace/messaging/chat_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobiledev_ecowaste/marketplace/simple_listing/listing_details_page.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _supabaseService = SupabaseService();
  bool _loading = true;
  List<Map<String, dynamic>> _transactions = [];
  final Map<String, String> _nameCache = {};
  RealtimeChannel? _txChannel;

  @override
  void initState() {
    super.initState();
    _load();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    final userId = _supabaseService.currentUser?.id;
    if (userId == null) return;
    _txChannel = _supabaseService.client.channel('realtime:market_transactions')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'market_transactions',
        callback: (payload) {
          final newRow = payload.newRecord;
          if (newRow == null) return;
          final sellerId = newRow['seller_id']?.toString();
          final buyerId = newRow['buyer_id']?.toString();
          if (sellerId == userId || buyerId == userId) {
            _load();
          }
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'market_transactions',
        callback: (payload) {
          final newRow = payload.newRecord;
          if (newRow == null) return;
          final sellerId = newRow['seller_id']?.toString();
          final buyerId = newRow['buyer_id']?.toString();
          if (sellerId == userId || buyerId == userId) {
            _load();
          }
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: 'market_transactions',
        callback: (payload) {
          _load();
        },
      )
      ..subscribe();
  }

  @override
  void dispose() {
    _txChannel?.unsubscribe();
    super.dispose();
  }

  Future<String> _getUserName(String userId) async {
    if (_nameCache.containsKey(userId)) return _nameCache[userId]!;
    final profile = await _supabaseService.getUserProfile(userId);
    final name = (profile != null ? (profile['name'] as String?) : null) ?? 'User';
    _nameCache[userId] = name;
    return name;
  }

  Future<void> _load() async {
    setState(() { _loading = true; });
    final userId = _supabaseService.currentUser?.id;
    if (userId == null) { if (mounted) setState(() { _loading = false; }); return; }
    final txs = await _supabaseService.getUserTransactionsDetailed(userId);
    if (!mounted) return;
    setState(() {
      _transactions = txs;
      _loading = false;
    });
  }

  Future<void> _confirmTx(Map<String, dynamic> tx) async {
    final type = tx['type'] as String? ?? '';
    final id = tx['id'] as String;
    String? err;
    if (type == 'sell') err = await _supabaseService.confirmSale(id);
    else if (type == 'trade') err = await _supabaseService.confirmTrade(id);
    else if (type == 'donate') err = await _supabaseService.confirmDonation(id);
    if (!mounted) return;
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text('Confirmation sent/processed')));
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text('Error: $err')));
    }
  }

  Future<void> _cancelTx(Map<String, dynamic> tx) async {
    final id = tx['id'] as String;
    final err = await _supabaseService.cancelTransaction(id);
    if (!mounted) return;
    if (err == null) {
      setState(() { _transactions.removeWhere((t) => t['id'] == id); });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction cancelled')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text('Error: $err')));
    }
  }

  void _messageOther(Map<String, dynamic> tx) async {
    final currentUserId = _supabaseService.currentUser?.id;
    final sellerId = tx['seller_id']?.toString();
    final buyerId = tx['buyer_id']?.toString();
    final otherUserId = currentUserId == sellerId ? buyerId : sellerId;
    if (otherUserId == null) return;
    final conversationId = await _supabaseService.getOrCreateConversation(otherUserId, listingId: tx['listing_id']?.toString());
    if (!mounted) return;
    if (conversationId != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(conversationId: conversationId, otherUserId: otherUserId, otherUserName: 'User')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _transactions.isEmpty
                  ? const Center(child: Text('No transactions yet'))
                  : ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final tx = _transactions[index];
                        final listing = tx['listings'] as Map<String, dynamic>?; // joined listing if available
                        final title = listing != null ? (listing['title'] as String? ?? 'Listing') : 'Listing';
                        final type = (tx['type'] as String?) ?? '';
                        final status = (tx['status'] as String?) ?? '';
                        final currentUserId = _supabaseService.currentUser?.id;
                        final sellerId = tx['seller_id']?.toString();
                        final buyerId = tx['buyer_id']?.toString();
                        final isSeller = currentUserId != null && currentUserId == sellerId;
                        final otherUserId = isSeller ? buyerId : sellerId;

                        return Card(
                          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: ListTile(
                            onTap: () async {
                              final fullListing = await _supabaseService.getListingById(tx['listing_id'] as String);
                              if (!mounted || fullListing == null) return;
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ListingDetailsPage(listing: fullListing)));
                            },
                            title: Text(title, style: GoogleFonts.splineSans(fontWeight: FontWeight.bold)),
                            subtitle: FutureBuilder<String>(
                              future: otherUserId != null ? _getUserName(otherUserId) : Future.value('Unknown'),
                              builder: (context, snapshot) {
                                final otherName = snapshot.data ?? 'User';
                                String line2;
                                if (status == 'pending' && !isSeller) {
                                  line2 = 'Waiting for seller confirmation';
                                } else if (status == 'pending' && isSeller) {
                                  line2 = 'Action required: confirm or cancel';
                                } else if (status == 'cancelled' && isSeller) {
                                  line2 = 'You cancelled this request';
                                } else if (status == 'cancelled' && !isSeller) {
                                  line2 = 'Seller cancelled your request';
                                } else if (status == 'completed') {
                                  line2 = 'Completed';
                                } else {
                                  line2 = status.isNotEmpty ? status[0].toUpperCase() + status.substring(1) : '';
                                }
                                final rolePrefix = isSeller ? 'Requested by ' : 'Seller: ';
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(rolePrefix),
                                        Text(
                                          otherName,
                                          style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blueAccent),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(line2, style: TextStyle(color: Colors.grey[700])),
                                    const SizedBox(height: 4),
                                    Text('Created ${(tx['created_at'] as String).toString()}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                );
                              },
                            ),
                            trailing: SizedBox(
                              width: 200,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (status == 'pending' && isSeller) ...[
                                    IconButton(
                                      tooltip: 'Confirm',
                                      onPressed: () => _confirmTx(tx),
                                      icon: const Icon(Icons.check_circle, color: Colors.green),
                                    ),
                                    IconButton(
                                      tooltip: 'Cancel',
                                      onPressed: () => _cancelTx(tx),
                                      icon: const Icon(Icons.cancel, color: Colors.red),
                                    ),
                                  ] else if (status == 'pending' && !isSeller) ...[
                                    IconButton(
                                      tooltip: 'Cancel request',
                                      onPressed: () => _cancelTx(tx),
                                      icon: const Icon(Icons.cancel, color: Colors.red),
                                    ),
                                  ],
                                  IconButton(
                                    tooltip: 'Message',
                                    onPressed: () => _messageOther(tx),
                                    icon: const Icon(Icons.chat_bubble_outline),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
