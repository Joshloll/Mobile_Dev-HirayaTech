import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/theme.dart';
import 'chat_page.dart';

class DeviceDetailsPage extends StatelessWidget {
  final Map<String, dynamic> device;

  const DeviceDetailsPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildContent(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatPage()),
            );
          },
          label: const Text('Start Chat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          icon: const Icon(Icons.chat_bubble_outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          extendedPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    final String imageUrl = device['imageUrl']!;
    final ImageProvider imageProvider = imageUrl.startsWith('assets/') ? AssetImage(imageUrl) : NetworkImage(imageUrl);
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: hirayaBlue,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16.0),
        title: Text(
          'Device Details',
          style: GoogleFonts.splineSans(
            fontWeight: FontWeight.bold,
            color: hirayaBlue,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image( image: imageProvider, fit: BoxFit.cover, ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ Colors.transparent, Colors.white.withOpacity(0.8), Colors.white, ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.3, 0.8, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: _buildHeader(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Text(
              device['description'] ?? 'No description provided.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16, height: 1.5),
            ),
          ),
          const Divider(indent: 24, endIndent: 24),
          _buildSpecsCard(),
          const Divider(indent: 24, endIndent: 24),
          _buildInclusionsCard(),
          const Divider(indent: 24, endIndent: 24),
          _buildVerificationCard(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String displayLine;
    TextStyle displayStyle;

    switch(device['category']) {
      case 'Donate':
        displayLine = 'For Donation';
        displayStyle = GoogleFonts.splineSans(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 24);
        break;
      case 'Trade':
        displayLine = 'Trade for: ${device['tradeDetails'] ?? 'N/A'}';
        displayStyle = GoogleFonts.splineSans(color: Colors.purple.shade700, fontWeight: FontWeight.bold, fontSize: 22);
        break;
      default: // Sell
        displayLine = '₱${device['price']!}';
        displayStyle = const TextStyle(
          fontFamily: 'Roboto',
          color: hirayaBlue,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          device['name']!,
          style: GoogleFonts.splineSans(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: hirayaBlue,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Chip(
              label: Text(device['condition']!, style: const TextStyle(fontWeight: FontWeight.w500)),
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(displayLine, style: displayStyle, textAlign: TextAlign.end,)),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Specifications'),
          const SizedBox(height: 12),
          _buildDetailRow('Storage', device['storage'] ?? 'N/A'),
          _buildDetailRow('Color', device['color'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInclusionsCard() {
    List<String> accessories = List<String>.from(device['accessories'] ?? []);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('What\'s Included'),
          const SizedBox(height: 12),
          _buildDetailRow('Accessories', accessories.isEmpty ? 'None' : accessories.join(', ')),
          _buildDetailRow('Repair History', device['repairHistory'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildVerificationCard() {
    Map<String, dynamic> verification = device['verification'] ?? {};
    String formatAnswer(bool? answer) => answer == null ? 'N/A' : (answer ? 'Yes' : 'No');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Condition Verification'),
          const SizedBox(height: 12),
          _buildDetailRow('Powers On Correctly', formatAnswer(verification['powersOn'] as bool?)),
          _buildDetailRow('Buttons Functional', formatAnswer(verification['buttonsFunctional'] as bool?)),
          _buildDetailRow('Battery Drains Fast', formatAnswer(verification['batteryDrainsFast'] as bool?)),
          _buildDetailRow('Screen Has Damage', formatAnswer(verification['screenDamage'] as bool?)),
          _buildDetailRow('Touchscreen Responsive', formatAnswer(verification['touchResponsive'] as bool?)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.splineSans(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: hirayaBlue,
      ),
    );
  }
}