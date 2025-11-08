import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/models/user_model.dart';
import 'package:mobiledev_ecowaste/settings/settings_page.dart';
import 'package:mobiledev_ecowaste/profile/edit_profile_page.dart';
import 'package:mobiledev_ecowaste/marketplace/device_details_page.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';
import 'package:mobiledev_ecowaste/marketplace/simple_listing/listing_details_page.dart';

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
      if (mounted) {
        setState(() {
          if (profileData != null) {
            _userProfile = UserProfile.fromJson(profileData);
          }
          _points = points;
          _pending = pending;
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
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Profile',
                onPressed: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfilePage()),
                  );
                  if (changed == true) {
                    _loadUserProfile();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                  if (changed == true) {
                    _loadUserProfile();
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(child: _buildProfileHeader()),
          SliverToBoxAdapter(child: _buildPointsRow()),
          // Removed Pending Transactions and Notifications sections per request
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
          _buildListingsList('sell'),
          _buildListingsList('trade'),
          _buildListingsList('donate'),
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

  Widget _buildListingsList(String type) {
    final userId = _supabaseService.currentUser?.id;
    if (userId == null) {
      return const Center(child: Text('Not signed in'));
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _supabaseService.getUserListings(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data!
            .where((l) => (l['listing_type'] as String?) == type)
            .toList();
        if (items.isEmpty) {
          return const Center(child: Text('No listings yet'));
        }
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = items[index];
            final images = item['image_urls'] as List?;
            final thumb = (images != null && images.isNotEmpty) ? images.first as String : null;
            return ListTile(
              leading: thumb != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(thumb, width: 56, height: 56, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported)),
                    )
                  : const CircleAvatar(child: Icon(Icons.devices)),
              title: Text(item['title'] as String? ?? 'Listing'),
              subtitle: Text((item['status'] as String?)?.toString().toUpperCase() ?? 'ACTIVE'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final listing = await _supabaseService.getListingById(item['id'] as String);
                if (!mounted || listing == null) return;
                Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailsPage(listing: listing)));
              },
            );
          },
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}