import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/theme.dart';
import 'chat_page.dart';

class DeviceDetailsPage extends StatefulWidget {
  final Map<String, dynamic> device;

  const DeviceDetailsPage({super.key, required this.device});

  @override
  State<DeviceDetailsPage> createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
  int _imageIndex = 0;

  Map<String, dynamic> get device => widget.device;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
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

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    final List<dynamic>? imageUrlsDyn = device['image_urls'] as List<dynamic>?;
    final List<String> imageUrls = imageUrlsDyn?.map((e) => e.toString()).toList() ?? [];
    final String? singleImage = device['imageUrl'] as String?;
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
            if (imageUrls.isNotEmpty)
              PageView.builder(
                itemCount: imageUrls.length,
                onPageChanged: (i) => setState(() => _imageIndex = i),
                itemBuilder: (_, i) => Image.network(
                  imageUrls[i],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image, size: 80)),
                ),
              )
            else if (singleImage != null)
              Image(
                image: singleImage.startsWith('assets/') ? AssetImage(singleImage) as ImageProvider : NetworkImage(singleImage),
                fit: BoxFit.cover,
              )
            else
              Container(
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.devices, size: 80, color: Colors.grey),
              ),
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
            if (imageUrls.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(imageUrls.length, (i) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _imageIndex ? hirayaBlue : Colors.white70,
                          border: Border.all(color: Colors.black12),
                        ),
                      )),
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
          if ((device['deviceType'] ?? device['device_type']) != null)
            _buildDetailRow('Device Type', (device['deviceType'] ?? device['device_type']).toString()),
          if (device['brand'] != null)
            _buildDetailRow('Brand', device['brand'].toString()),
          if (device['model'] != null)
            _buildDetailRow('Model', device['model'].toString()),
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
          const SizedBox(height: 12),
          _buildSectionTitle('Verification Proofs'),
          const SizedBox(height: 8),
          _buildProofs(verification),
        ],
      ),
    );
  }

  Widget _buildProofs(Map<String, dynamic> verification) {
    final batteryPhotoUrl =
        verification['batteryPhotoUrl'] ?? device['batteryPhotoUrl'] ?? verification['battery_photo_url'] ?? device['battery_photo_url'];
    final screenDamagePhotoUrl =
        verification['screenDamagePhotoUrl'] ?? device['screenDamagePhotoUrl'] ?? verification['screen_damage_photo_url'] ?? device['screen_damage_photo_url'];
    final functionalityVideoUrl =
        verification['functionalityVideoUrl'] ?? device['functionalityVideoUrl'] ?? verification['functionality_video_url'] ?? device['functionality_video_url'];
    final powersOnVideoUrl =
        verification['powersOnVideoUrl'] ?? device['powersOnVideoUrl'] ?? verification['powers_on_video_url'] ?? device['powers_on_video_url'];
    final buttonsVideoUrl =
        verification['buttonsVideoUrl'] ?? device['buttonsVideoUrl'] ?? verification['buttons_video_url'] ?? device['buttons_video_url'];
    final touchscreenVideoUrl =
        verification['touchscreenVideoUrl'] ?? device['touchscreenVideoUrl'] ?? verification['touchscreen_video_url'] ?? device['touchscreen_video_url'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (batteryPhotoUrl is String && batteryPhotoUrl.isNotEmpty) ...[
          Text('Battery Photo', style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              batteryPhotoUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (screenDamagePhotoUrl is String && screenDamagePhotoUrl.isNotEmpty) ...[
          Text('Screen Damage Photo', style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              screenDamagePhotoUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (functionalityVideoUrl is String && functionalityVideoUrl.isNotEmpty) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.videocam_outlined),
            title: const Text('Functionality Video'),
            subtitle: Text(functionalityVideoUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: TextButton(
              onPressed: () => _showLinkDialog(context, functionalityVideoUrl),
              child: const Text('Open'),
            ),
          ),
        ],
        if (powersOnVideoUrl is String && powersOnVideoUrl.isNotEmpty) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.power_settings_new_outlined),
            title: const Text('Powers On Video'),
            subtitle: Text(powersOnVideoUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: TextButton(
              onPressed: () => _showLinkDialog(context, powersOnVideoUrl),
              child: const Text('Open'),
            ),
          ),
        ],
        if (buttonsVideoUrl is String && buttonsVideoUrl.isNotEmpty) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.smart_button_outlined),
            title: const Text('Buttons Functional Video'),
            subtitle: Text(buttonsVideoUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: TextButton(
              onPressed: () => _showLinkDialog(context, buttonsVideoUrl),
              child: const Text('Open'),
            ),
          ),
        ],
        if (touchscreenVideoUrl is String && touchscreenVideoUrl.isNotEmpty) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.touch_app_outlined),
            title: const Text('Touchscreen Responsive Video'),
            subtitle: Text(touchscreenVideoUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: TextButton(
              onPressed: () => _showLinkDialog(context, touchscreenVideoUrl),
              child: const Text('Open'),
            ),
          ),
        ],
        if (!(batteryPhotoUrl is String && batteryPhotoUrl.isNotEmpty)
            && !(screenDamagePhotoUrl is String && screenDamagePhotoUrl.isNotEmpty)
            && !(functionalityVideoUrl is String && functionalityVideoUrl.isNotEmpty)
            && !(powersOnVideoUrl is String && powersOnVideoUrl.isNotEmpty)
            && !(buttonsVideoUrl is String && buttonsVideoUrl.isNotEmpty)
            && !(touchscreenVideoUrl is String && touchscreenVideoUrl.isNotEmpty))
          Text('No verification proofs provided.', style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  void _showLinkDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Video'),
        content: SelectableText(url),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied to clipboard')));
            },
            child: const Text('Copy link'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
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