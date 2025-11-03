import 'package:flutter/material.dart';
import 'device_details_page.dart';

class AllDevicesPage extends StatelessWidget {
  final List<Map<String, dynamic>> allDevices;

  const AllDevicesPage({super.key, required this.allDevices});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Devices'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: allDevices.length,
        itemBuilder: (context, index) {
          final device = allDevices[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceDetailsPage(device: device),
                ),
              );
            },
            child: _buildDeviceCard(context, device),
          );
        },
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, Map<String, dynamic> device) {
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
            fontFamily: 'Roboto',
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