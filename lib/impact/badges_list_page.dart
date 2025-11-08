import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BadgesListPage extends StatelessWidget {
  final int points;
  const BadgesListPage({super.key, required this.points});

  List<Map<String, dynamic>> _badgesData(int pts) {
    final earned = <String>{};
    if (pts >= 300) earned.add('Recycle Rookie');
    if (pts >= 700) earned.add('Saver Titan');
    if (pts >= 1000) earned.add('Kid of Mother Nature');
    return [
      {
        'name': 'Recycle Rookie',
        'image': 'assets/images/badge_rookie.png',
        'desc': 'Awarded for reaching 300 points.',
        'earned': earned.contains('Recycle Rookie'),
      },
      {
        'name': 'Saver Titan',
        'image': 'assets/images/badge_titan.png',
        'desc': 'Awarded for reaching 700 points.',
        'earned': earned.contains('Saver Titan'),
      },
      {
        'name': 'Kid of Mother Nature',
        'image': 'assets/images/badge_duke.png',
        'desc': 'Awarded for reaching 1000 points.',
        'earned': earned.contains('Kid of Mother Nature'),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final badges = _badgesData(points);
    return Scaffold(
      appBar: AppBar(title: const Text('All Badges')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: badges.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final b = badges[index];
          return Card(
            color: Colors.grey.shade100,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage(b['image'] as String),
                  ),
                  if (!(b['earned'] as bool))
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.65),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                b['name'] as String,
                style: GoogleFonts.splineSans(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(b['desc'] as String),
              trailing: (b['earned'] as bool)
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.lock_outline, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
