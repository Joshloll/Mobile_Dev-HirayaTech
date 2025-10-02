import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecyclingFinderPage extends StatelessWidget {
  const RecyclingFinderPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- MODIFIED: Locations reverted back to Davao City ---
    final List<Map<String, String>> centers = [
      {
        'name': 'Davao Eco-Recyclers',
        'address': 'Buhangin-Cabantian Rd, Buhangin, Davao City',
      },
      {
        'name': 'Mindanao Plastic Recycle',
        'address': 'Km. 5, Buhangin, Davao City, Davao del Sur',
      },
      {
        'name': 'Holcim Lugan Davao',
        'address': 'Sitio Lugan, Malagamot, Panacan, Davao City',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D3557),
        centerTitle: true,
        title: Text('Find Recycling Centers', style: GoogleFonts.splineSans(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          _buildSearchBar(),
          _buildMapView(),
          _buildFilterChips(),
          _buildCentersList(centers),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for recycling centers or address',
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: Colors.grey.shade200,
            child: Image.asset(
              'assets/images/map.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text(
                    'Could not load map image.\nPlease ensure it is in assets/images/',
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ActionChip(
            avatar: const Icon(Icons.near_me_outlined, size: 16),
            label: const Text('Distance'),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Icon(Icons.build_circle_outlined, size: 16),
            label: const Text('Materials'),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCentersList(List<Map<String, String>> centers) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // --- MODIFIED: Title reverted back to Davao City ---
            'Nearby Centers in Davao City',
            style: GoogleFonts.splineSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D3557),
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: centers.length,
            itemBuilder: (context, index) {
              return _buildCenterTile(centers[index]);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
          )
        ],
      ),
    );
  }

  Widget _buildCenterTile(Map<String, String> center) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.recycling_rounded, color: Color(0xFF1D3557), size: 30),
        ),
        title: Text(center['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(center['address']!),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to a details page for the recycling center
        },
      ),
    );
  }
}