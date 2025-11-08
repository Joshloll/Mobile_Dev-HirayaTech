import 'package:flutter/material.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';

class SelectPartnerListingPage extends StatefulWidget {
  const SelectPartnerListingPage({super.key});

  @override
  State<SelectPartnerListingPage> createState() => _SelectPartnerListingPageState();
}

class _SelectPartnerListingPageState extends State<SelectPartnerListingPage> {
  final _supabase = SupabaseService();
  bool _loading = true;
  List<Map<String, dynamic>> _myTradeables = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; });
    final uid = _supabase.currentUser?.id;
    if (uid == null) { if (mounted) setState(() { _loading = false; }); return; }
    final all = await _supabase.getUserListings(uid);
    final tradeables = all.where((l) => (l['listing_type'] as String?) == 'trade').toList();
    if (!mounted) return;
    setState(() { _myTradeables = tradeables; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a listing to trade')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _myTradeables.isEmpty
              ? const Center(child: Text('You have no trade listings yet.'))
              : ListView.separated(
                  itemCount: _myTradeables.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _myTradeables[index];
                    final images = item['image_urls'] as List?;
                    final thumb = (images != null && images.isNotEmpty) ? images.first as String : null;
                    return ListTile(
                      leading: thumb != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(thumb, width: 54, height: 54, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported)),
                            )
                          : const CircleAvatar(child: Icon(Icons.swap_horiz)),
                      title: Text(item['title'] as String? ?? 'Listing'),
                      subtitle: Text('Tap to select'),
                      onTap: () => Navigator.pop(context, item['id'] as String),
                    );
                  },
                ),
    );
  }
}
