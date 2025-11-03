import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';

class DonationJourneyPage extends StatelessWidget {
  final Map<String, String> item;
  const DonationJourneyPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final int completedSteps = item['status'] == 'Redistributed' ? 2 : 1;
    final List<Map<String, dynamic>> processes = [
      {'title': 'Device Received', 'subtitle': 'Received at our facility', 'icon': Icons.inventory_2_outlined},
      {'title': 'Device Refurbished', 'subtitle': 'Device is now ready for distribution', 'icon': Icons.construction_outlined},
      {'title': 'Device Distributed', 'subtitle': 'Distributed to a beneficiary', 'icon': Icons.handshake_outlined},
      {'title': 'Acknowledgment', 'subtitle': 'Beneficiary has acknowledged receipt', 'icon': Icons.sentiment_satisfied_outlined},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Donation Journey')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildTimeline(context, processes, completedSteps),
          const SizedBox(height: 32),
          _buildImpactCard(context),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, List<Map<String, dynamic>> processes, int completedSteps) {
    return FixedTimeline.tileBuilder(
      theme: TimelineThemeData(
        nodePosition: 0,
        color: Colors.grey.shade300,
        indicatorTheme: const IndicatorThemeData(position: 0, size: 40.0),
        connectorTheme: const ConnectorThemeData(thickness: 2.5),
      ),
      builder: TimelineTileBuilder.connected(
        itemCount: processes.length,
        contentsAlign: ContentsAlign.basic,
        oppositeContentsBuilder: (context, index) => const SizedBox(width: 16),
        contentsBuilder: (context, index) => Padding(
          // --- FIX: Added left padding to give text more space ---
          padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(processes[index]['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: index <= completedSteps ? Theme.of(context).colorScheme.primary : Colors.grey.shade500)),
              const SizedBox(height: 4),
              Text(processes[index]['subtitle'], style: TextStyle(color: index <= completedSteps ? Colors.grey.shade700 : Colors.grey.shade400)),
            ],
          ),
        ),
        indicatorBuilder: (context, index) => DotIndicator(
            color: index <= completedSteps ? Theme.of(context).colorScheme.secondary : Colors.grey.shade300,
            child: Icon(processes[index]['icon'], color: index <= completedSteps ? Colors.white : Colors.grey.shade500, size: 20)),
        connectorBuilder: (context, index, type) => SolidLineConnector(
            color: index < completedSteps ? Theme.of(context).colorScheme.secondary : Colors.grey.shade300),
      ),
    );
  }

  Widget _buildImpactCard(BuildContext context) { return Container( padding: const EdgeInsets.all(16.0), decoration: BoxDecoration( color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16), ), child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( 'Your Impact', style: TextStyle( color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16, ), ), const SizedBox(height: 8), Text( 'Follow the journey of your donated device as it gets refurbished and finds a new home. Your contribution makes a real difference!', style: TextStyle(color: Colors.grey.shade700, height: 1.5), ), ], ), ); }
}