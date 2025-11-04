import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';
import 'package:mobiledev_ecowaste/marketplace/messaging/chat_page.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
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
      appBar: AppBar(title: const Text('Transactions')),
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
                        final type = (tx['type'] as String?)?.toUpperCase() ?? '';
                        final status = (tx['status'] as String?)?.toUpperCase() ?? '';
                        return Card(
                          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: ListTile(
                            onTap: () async {
                              final listing = await _supabaseService.getListingById(tx['listing_id'] as String);
                              if (!mounted || listing == null) return;
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ListingDetailsPage(listing: listing)));
                            },
                            title: Text('$type • $status', style: GoogleFonts.splineSans(fontWeight: FontWeight.bold)),
                            subtitle: Text('Created ${(tx['created_at'] as String).toString()}'),
                            trailing: SizedBox(
                              width: 180,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
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
