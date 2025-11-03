import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/models/user_model.dart';
import 'package:mobiledev_ecowaste/settings/settings_page.dart';
import 'package:mobiledev_ecowaste/marketplace/device_details_page.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabaseService = SupabaseService();
  UserProfile? _userProfile;
  bool _isLoading = true;
  int _points = 0;
  List<Map<String, dynamic>> _pending = [];
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() { 
    super.initState(); 
    _tabController = TabController(length: 3, vsync: this);
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _supabaseService.currentUser;
    if (user != null) {
      final profileData = await _supabaseService.getUserProfile(user.id);
      final points = await _supabaseService.getCurrentUserPoints();
      final txs = await _supabaseService.getUserTransactionsDetailed(user.id);
      final pending = txs.where((t) => (t['status'] as String?) == 'pending').toList();
      final notifs = await _supabaseService.getNotifications();
      if (mounted) {
        setState(() {
          if (profileData != null) {
            _userProfile = UserProfile.fromJson(profileData);
          }
          _points = points;
          _pending = pending;
          _notifications = notifs;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            title: const Text('Profile'),
            actions: [ IconButton( icon: const Icon(Icons.settings_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()))), ],
          ),
          SliverToBoxAdapter(child: _buildProfileHeader()),
          SliverToBoxAdapter(child: _buildPointsRow()),
          SliverToBoxAdapter(child: _buildPendingSection()),
          SliverToBoxAdapter(child: _buildNotificationsSection()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text('My Listings', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            ),
          ),
          SliverPersistentHeader(
            delegate: _SliverTabBarDelegate(
              // --- FIX: Removed hardcoded colors ---
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'For Sale'),
                  Tab(text: 'For Trade'),
                  Tab(text: 'For Donation'),
                ],
              ),
            ),
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListingsList('sale'),
          _buildListingsList('trade'),
          _buildListingsList('donation'),
        ],
      ),
    );
  }

  // ... Unchanged helper methods below ...
  Widget _buildProfileHeader() { 
    if (_isLoading) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_userProfile == null) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
        child: const Center(child: Text('Unable to load profile')),
      );
    }

    return Container( 
      color: Colors.white, 
      padding: const EdgeInsets.symmetric(horizontal: 16.0), 
      child: Column( 
        children: [ 
          CircleAvatar( 
            radius: 40, 
            backgroundImage: _userProfile!.avatarUrl.isNotEmpty ? NetworkImage(_userProfile!.avatarUrl) : null,
            child: _userProfile!.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
          ), 
          const SizedBox(height: 12), 
          Text( 
            _userProfile!.name, 
            style: GoogleFonts.splineSans(fontWeight: FontWeight.bold, fontSize: 22), 
          ), 
          const SizedBox(height: 4), 
          Text('Member since ${_userProfile!.createdAt.year}', style: TextStyle(color: Colors.grey.shade600)), 
        ], 
      ), 
    ); 
  }

  Widget _buildPointsRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          const Icon(Icons.stars, color: Color(0xFF3A86FF)),
          const SizedBox(width: 8),
          Text('Impact Points: $_points', style: GoogleFonts.splineSans(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPendingSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pending Transactions (${_pending.length})', style: GoogleFonts.splineSans(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_pending.isEmpty) Text('No pending transactions', style: TextStyle(color: Colors.grey.shade600))
          else ..._pending.map((t) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.hourglass_top, color: Colors.amber),
            title: Text('${(t['type'] as String).toUpperCase()} - ${(t['status'] as String).toUpperCase()}'),
            subtitle: Text(DateTime.parse(t['created_at'] as String).toLocal().toString()),
          )),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notifications (${_notifications.length})', style: GoogleFonts.splineSans(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_notifications.isEmpty) Text('No notifications', style: TextStyle(color: Colors.grey.shade600))
          else ..._notifications.map((n) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.notifications),
            title: Text(n['title'] as String),
            subtitle: Text((n['body'] as String?) ?? ''),
          )),
        ],
      ),
    );
  }
  Widget _buildListingsList(String type) { final allItems = [ { 'name': 'iPhone 13 Pro', 'status': 'Active', 'type': 'sale', 'imageUrl': 'assets/images/ip13.png', 'condition': 'Excellent condition', 'price': '45,000', 'category': 'Sell', 'description': 'A top-tier flagship phone with a stunning ProMotion display.', 'storage': '256GB', 'color': 'Sierra Blue', 'accessories': ['Original Box', 'Charger & Cable'], 'repairHistory': 'None', 'verification': { 'powersOn': true, 'buttonsFunctional': true, 'batteryDrainsFast': false, 'screenDamage': false, 'touchResponsive': true } }, { 'name': 'Samsung Galaxy S22', 'status': 'Pending Review', 'type': 'sale', 'imageUrl': 'assets/images/samsung.png', 'condition': 'Like new', 'price': '35,000', 'category': 'Sell', 'description': 'Compact and powerful Android flagship with a vibrant display.', 'storage': '128GB', 'color': 'Phantom Black', 'accessories': ['Original Box', 'Charger & Cable'], 'repairHistory': 'None', 'verification': { 'powersOn': true, 'buttonsFunctional': true, 'batteryDrainsFast': false, 'screenDamage': false, 'touchResponsive': true } }, { 'name': 'MacBook Pro 16"', 'status': 'Traded', 'type': 'trade', 'imageUrl': 'https://images.unsplash.com/photo-1542393545-10f5cde2c810?w=100', 'condition': 'Barely used', 'price': '70,000', 'category': 'Trade', 'tradeDetails': 'Dell XPS 17', 'description': 'A high-performance laptop for creative professionals.', 'storage': '512GB SSD', 'color': 'Space Gray', 'accessories': ['Charger & Cable'], 'repairHistory': 'None', 'verification': { 'powersOn': true, 'buttonsFunctional': true, 'batteryDrainsFast': false, 'screenDamage': false, 'touchResponsive': true } }, { 'name': 'iPad Air', 'status': 'Active', 'type': 'trade', 'imageUrl': 'assets/images/ipad.png', 'condition': 'Good condition', 'price': '25,000', 'category': 'Trade', 'tradeDetails': 'Samsung Tab S8', 'description': 'Lightweight and versatile tablet with M1 power.', 'storage': '64GB', 'color': 'Starlight', 'accessories': ['Charger & Cable'], 'repairHistory': 'Screen replaced', 'verification': { 'powersOn': true, 'buttonsFunctional': true, 'batteryDrainsFast': false, 'screenDamage': false, 'touchResponsive': true } }, { 'name': 'Sony WH-1000XM4', 'status': 'Donated', 'type': 'donation', 'imageUrl': 'assets/images/sony.png', 'condition': 'Used', 'price': '0', 'category': 'Donate', 'description': 'Industry-leading noise-cancelling headphones.', 'storage': 'N/A', 'color': 'Black', 'accessories': ['Carrying Case'], 'repairHistory': 'None', 'verification': { 'powersOn': true, 'buttonsFunctional': true, 'batteryDrainsFast': false } }, ]; final filteredItems = allItems.where((item) => (item['type'] as String) == type).toList(); if (filteredItems.isEmpty) { return Container( color: Colors.white, child: Center( child: Text('No items listed for $type.', style: const TextStyle(color: Colors.grey)))); } return Container( color: Colors.white, child: ListView.builder( itemCount: filteredItems.length, itemBuilder: (context, index) { return _buildListingTile(filteredItems[index]); }, ), ); }
  Color _getStatusColor(String status) { switch (status) { case 'Active': return Colors.green.shade500; case 'Pending Review': return Colors.amber.shade600; default: return Colors.grey.shade500; } }
  Widget _buildListingTile(Map<String, dynamic> item) { final String imageUrl = item['imageUrl']! as String; final ImageProvider imageProvider = imageUrl.startsWith('assets/') ? AssetImage(imageUrl) : NetworkImage(imageUrl); return Container( color: Colors.white, child: ListTile( leading: ClipRRect( borderRadius: BorderRadius.circular(8), child: Image( image: imageProvider, width: 56, height: 56, fit: BoxFit.cover, ), ), title: Text(item['name']! as String, style: const TextStyle(fontWeight: FontWeight.w500)), subtitle: Row( children: [ Container( width: 8, height: 8, decoration: BoxDecoration( shape: BoxShape.circle, color: _getStatusColor(item['status']! as String)), ), const SizedBox(width: 6), Text(item['status']! as String), ], ), trailing: const Icon(Icons.chevron_right), onTap: () { Navigator.push( context, MaterialPageRoute( builder: (context) => DeviceDetailsPage(device: item), ), ); }, ), ); }
}
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate { _SliverTabBarDelegate(this._tabBar); final TabBar _tabBar; @override double get minExtent => _tabBar.preferredSize.height; @override double get maxExtent => _tabBar.preferredSize.height; @override Widget build( BuildContext context, double shrinkOffset, bool overlapsContent) { return Container(color: Colors.white, child: _tabBar); } @override bool shouldRebuild(_SliverTabBarDelegate oldDelegate) { return false; } }