import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/theme.dart'; // Import theme for colors

class ImpactPage extends StatelessWidget {
  const ImpactPage({super.key});

  @override
  Widget build(BuildContext context) {
    // The main build method calls the helper methods below.
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildStatsCards(),
          _buildNextBadgeProgress(context),
          _buildSectionHeader('Badges Earned', 'View All', () {}),
          _buildBadgesGrid(),
          _buildSectionHeader('Leaderboard', 'This Week', () {}),
          _buildLeaderboardList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- ALL HELPER METHODS ARE INSIDE THE ImpactPage CLASS ---

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard('1,250', 'Points'),
              const SizedBox(width: 12),
              _buildStatCard('3', 'Badges'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('15', 'Devices Saved'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.splineSans(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: hirayaBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextBadgeProgress(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: 'Next Badge: ',
              style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
              children: const [
                TextSpan(
                  text: 'Eco-Warrior',
                  style: TextStyle(fontWeight: FontWeight.bold, color: hirayaBlue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              value: 0.75,
              minHeight: 10,
              // Color is now inherited from the global theme
              backgroundColor: Theme.of(context).progressIndicatorTheme.linearTrackColor,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              '500 points to go',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText, VoidCallback onAction) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.splineSans(
              color: hirayaBlue,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          TextButton(
            onPressed: onAction,
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid() {
    final badges = [
      {'name': 'Recycle Rookie', 'image': 'assets/images/badge_rookie.png'},
      {'name': 'Trade Titan', 'image': 'assets/images/badge_titan.png'},
      {'name': 'Donation Duke', 'image': 'assets/images/badge_duke.png'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: badges.map((badge) {
          return Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: AssetImage(badge['image']!),
              ),
              const SizedBox(height: 8),
              Text(badge['name']!, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    final leaderboard = [
      { 'rank': '1', 'name': 'Ethan Carter', 'points': '1,500 points', 'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100', 'isTop': true },
      { 'rank': '2', 'name': 'Sophia Lee', 'points': '1,450 points', 'avatar': 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=100', 'isTop': false },
      { 'rank': '3', 'name': 'Noah Williams', 'points': '1,300 points', 'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100', 'isTop': false },
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: leaderboard.map((entry) {
          return Card(
            elevation: 0,
            color: Colors.grey.shade100,
            margin: const EdgeInsets.only(bottom: 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    entry['rank']! as String,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: hirayaBlue),
                  ),
                  const SizedBox(width: 16),
                  CircleAvatar(backgroundImage: NetworkImage(entry['avatar']! as String)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry['name']! as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(entry['points']! as String, style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  if (entry['isTop']! as bool) Icon(Icons.emoji_events, color: Colors.amber.shade600, size: 28),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
} // <-- IMPORTANT: Make sure all helper methods are ABOVE this closing brace