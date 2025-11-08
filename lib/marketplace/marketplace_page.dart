import 'package:flutter/material.dart';
import 'package:mobiledev_ecowaste/community_feed/functional_community_feed_page.dart';
// import 'package:mobiledev_ecowaste/donate/donate_page.dart';

import 'package:mobiledev_ecowaste/impact/impact_page.dart';
import 'package:mobiledev_ecowaste/profile/profile_page.dart';
import 'package:mobiledev_ecowaste/widgets/app_drawer.dart';

import 'chats_list_page.dart';
import 'simple_listing/listing_type_selection_page.dart';
import 'simple_listing/listings_feed_page.dart';
import 'transactions_page.dart';
import 'package:provider/provider.dart';
import 'add_listing/listing_form_provider.dart';
import 'add_listing/add_listing_step2_type_page.dart';
import 'all_devices_page.dart';
import 'device_details_page.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  int _bottomNavIndex = 0;

  final List<Widget> _pages = const <Widget>[
    ListingsFeedPage(),
    FunctionalCommunityFeedPage(),
    TransactionsPage(),
    ImpactPage(),
    ProfilePage(),
  ];

  AppBar? _buildAppBar() {
    if (_bottomNavIndex == 4) {
      return null;
    }

    String title;
    List<Widget>? actions;

    switch (_bottomNavIndex) {
      case 1:
        title = 'Community';
        actions = []; // FAB is now in the community page itself
        break;
      case 2:
        title = 'Transactions';
        actions = [];
        break;
      case 3:
        title = 'My Impact';
        actions = [];
        break;
      default:
        title = 'Marketplace';
        actions = [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.chat_bubble_outline, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatsListPage()),
                );
              },
            ),
          ),
        ];
        break;
    }

    return AppBar(
      title: Text(title),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      elevation: _bottomNavIndex == 1 ? 1 : 0,
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Market'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart_outlined), activeIcon: Icon(Icons.show_chart), label: 'Impact'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: _bottomNavIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                final provider = ListingFormProvider();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: provider,
                      child: const AddListingStep2TypePage(),
                    ),
                  ),
                );
              },
              label: const Text('List a Device'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _MarketplaceBody extends StatefulWidget {
  const _MarketplaceBody();
  @override
  State<_MarketplaceBody> createState() => _MarketplaceBodyState();
}

class _MarketplaceBodyState extends State<_MarketplaceBody> {
  final List<String> _categories = ['All', 'Sell', 'Trade', 'Donate'];
  String _selectedCategory = 'All';
  List<Map<String, dynamic>> _filteredDevices = [];

  final List<Map<String, dynamic>> _allDevices = [
    {
      'name': 'iPhone 13 Pro', 'condition': 'Excellent condition', 'price': '45,000', 'imageUrl': 'assets/images/ip13.png', 'category': 'Sell', 'tradeDetails': '',
      'description': 'A top-tier flagship phone with a stunning ProMotion display and powerful A15 Bionic chip. Perfect for photography and performance.',
      'storage': '256GB', 'color': 'Sierra Blue', 'accessories': ['Original Box', 'Charger & Cable'], 'repairHistory': 'None',
      'verification': { 'powersOn': true, 'buttonsFunctional': true, 'batteryDrainsFast': false, 'screenDamage': false, 'touchResponsive': true }
    },
    {
      'name': 'Samsung Galaxy S22', 'condition': 'Like new', 'price': '35,000', 'imageUrl': 'assets/images/samsung.png', 'category': 'Sell', 'tradeDetails': '',
      'description': 'Compact and powerful Android flagship with a vibrant display and versatile camera system. Comes with all original accessories.',
      'storage': '128GB', 'color': 'Phantom Black', 'accessories': ['Original Box', 'Charger & Cable'], 'repairHistory': 'None',
      'verification': { 'powersOn': true, 'buttonsFunctional': true, 'batteryDrainsFast': false, 'screenDamage': false, 'touchResponsive': true }
    },
    {
      'name': 'Bose QuietComfort Ultra', 'condition': 'Brand new', 'price': '22,500', 'imageUrl': 'assets/images/bose.png', 'category': 'Sell', 'tradeDetails': '',
      'description': 'Experience world-class noise cancellation and immersive audio with these brand new, unopened Bose headphones.',
      'storage': 'N/A', 'color': 'Black', 'accessories': ['Original Box', 'Charger & Cable', 'Carrying Case'], 'repairHistory': 'None',
      'verification': { 'powersOn': true, 'buttonsFunctional': true, 'batteryDrainsFast': false }
    },
    {
      'name': 'Dell XPS 15', 'condition': 'Slightly used', 'price': '65,000', 'imageUrl': 'assets/images/dell.png', 'category': 'Trade', 'tradeDetails': 'MacBook Air M2',
      'description': 'A high-performance Windows laptop with a gorgeous 4K display. Ideal for creative professionals looking to trade.',
      'storage': '512GB SSD', 'color': 'Silver', 'accessories': ['Charger & Cable'], 'repairHistory': 'None',
      'verification': { 'powersOn': true, 'buttonsFunctional': true, 'batteryDrainsFast': false, 'screenDamage': false, 'touchResponsive': true }
    },
    {
      'name': 'Google Pixel 8 Pro', 'condition': 'Good condition', 'price': '48,000', 'imageUrl': 'assets/images/pixel.png', 'category': 'Trade', 'tradeDetails': 'iPhone 14 Pro',
      'description': 'The pinnacle of AI-powered photography in a smartphone. Great condition, ready for a new home via trade.',
      'storage': '256GB', 'color': 'Obsidian', 'accessories': ['Charger & Cable'], 'repairHistory': 'None',
      'verification': { 'powersOn': true, 'buttonsFunctional': true, 'batteryDrainsFast': false, 'screenDamage': false, 'touchResponsive': true }
    },
    {
      'name': 'iPad Air', 'condition': 'Good condition', 'price': '25,000', 'imageUrl': 'assets/images/ipad.png', 'category': 'Trade', 'tradeDetails': 'Samsung Tab S8',
      'description': 'Lightweight and versatile tablet with M1 power. Perfect for students and artists. Minor scuffs on the back.',
      'storage': '64GB', 'color': 'Starlight', 'accessories': ['Charger & Cable'], 'repairHistory': 'Screen replaced by certified technician',
      'verification': { 'powersOn': true, 'buttonsFunctional': true, 'batteryDrainsFast': false, 'screenDamage': false, 'touchResponsive': true }
    },
    {
      'name': 'Sony WH-1000XM4', 'condition': 'Used', 'price': '0', 'imageUrl': 'assets/images/sony.png', 'category': 'Donate', 'tradeDetails': '',
      'description': 'Industry-leading noise-cancelling headphones. Fully functional and ready to be donated to a good cause.',
      'storage': 'N/A', 'color': 'Black', 'accessories': ['Carrying Case'], 'repairHistory': 'None',
      'verification': { 'powersOn': true, 'buttonsFunctional': true, 'batteryDrainsFast': false }
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredDevices = List.from(_allDevices);
  }

  void _updateFilter(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredDevices = List.from(_allDevices);
      } else {
        _filteredDevices = _allDevices.where((device) => device['category'] == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          _buildSectionHeader('Featured Devices', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllDevicesPage(allDevices: _allDevices),
              ),
            );
          }),
          _buildDeviceGrid(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for devices',
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                _updateFilter(category);
              }
            },
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          TextButton(onPressed: onSeeAll, child: const Text('See all')),
        ],
      ),
    );
  }

  Widget _buildDeviceGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: _filteredDevices.length,
      itemBuilder: (context, index) {
        final device = _filteredDevices[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeviceDetailsPage(device: device),
              ),
            );
          },
          child: _buildDeviceCard(device),
        );
      },
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final String imageUrl = device['imageUrl']!;
    final ImageProvider imageProvider = imageUrl.startsWith('assets/') ? AssetImage(imageUrl) : NetworkImage(imageUrl);
    String displayLine;
    TextStyle displayStyle;

    switch(device['category']) {
      case 'Donate':
        displayLine = 'For Donation';
        displayStyle = TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 16);
        break;
      case 'Trade':
        displayLine = 'Trade for: ${device['tradeDetails'] ?? 'N/A'}';
        displayStyle = TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold, fontSize: 16);
        break;
      default: // Sell
        displayLine = '₱${device['price']! as String}';
        displayStyle = TextStyle(
            fontFamily: 'Roboto', // Use a font that supports the Peso sign
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18
        );
    }

    return Container(
      decoration: BoxDecoration( color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16), ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                image: DecorationImage( image: imageProvider, fit: BoxFit.cover, ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device['name']! as String, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis,),
                const SizedBox(height: 2),
                Text(device['condition']! as String, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 6),
                Text(displayLine, style: displayStyle, maxLines: 2, overflow: TextOverflow.ellipsis,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}