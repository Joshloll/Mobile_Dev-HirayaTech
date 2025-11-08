import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/theme.dart'; // Import theme for colors
import 'package:mobiledev_ecowaste/services/supabase_service.dart';
import 'package:mobiledev_ecowaste/profile/public_profile_page.dart';
import 'package:mobiledev_ecowaste/impact/badges_list_page.dart';

class ImpactPage extends StatefulWidget {
  const ImpactPage({super.key});

  @override
  State<ImpactPage> createState() => _ImpactPageState();
}

class _ImpactPageState extends State<ImpactPage> {
  final _supabaseService = SupabaseService();
  int _points = 0;
  int _devices = 0;
  List<Map<String, dynamic>> _leaderboard = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; });
    final points = await _supabaseService.getCurrentUserPoints();
    final leaderboard = await _supabaseService.getLeaderboard(limit: 10);
    // Try to fetch devices from user_points (devices field)
    int devices = 0;
    try {
      final user = _supabaseService.currentUser;
      if (user != null) {
        final res = await _supabaseService.client
            .from('user_points')
            .select('devices')
            .eq('user_id', user.id)
            .maybeSingle();
        if (res != null) {
          devices = (res['devices'] as int? ?? 0);
        }
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() { _points = points; _devices = devices; _leaderboard = leaderboard; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          children: [
            const SizedBox(height: 16),
            _buildStatsCards(),
            _buildNextBadgeProgress(context),
            _buildSectionHeader('Badges Earned', 'View All', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BadgesListPage(points: _points),
                ),
              );
            }),
            _buildBadgesGrid(),
            _buildSectionHeader('Leaderboard', 'This Week', () {}),
            _buildLeaderboardList(),
            const SizedBox(height: 24),
          ],
        ),
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
              _buildStatCard('$_points', 'Points'),
              const SizedBox(width: 12),
              _buildStatCard('3', 'Badges'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('$_devices', 'Devices Saved'),
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
    final earned = _earnedBadges(_points);
    final badges = [
      {'name': 'Recycle Rookie', 'image': 'assets/images/badge_rookie.png', 'earned': earned.contains('Recycle Rookie')},
      {'name': 'Saver Titan', 'image': 'assets/images/badge_titan.png', 'earned': earned.contains('Saver Titan')},
      {'name': 'Kid of Mother Nature', 'image': 'assets/images/badge_duke.png', 'earned': earned.contains('Kid of Mother Nature')},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: badges.map((badge) {
          return Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: AssetImage(badge['image'] as String),
                  ),
                  if (!(badge['earned'] as bool))
                    Positioned.fill(child: Container(decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), shape: BoxShape.circle))),
                ],
              ),
              const SizedBox(height: 8),
              Text(badge['name'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<String> _earnedBadges(int points) {
    final res = <String>[];
    if (points >= 300) res.add('Recycle Rookie');
    if (points >= 700) res.add('Saver Titan');
    if (points >= 1000) res.add('Kid of Mother Nature');
    return res;
  }

  Widget _buildLeaderboardList() {
    final leaderboard = _leaderboard.asMap().entries.map((e) {
      final i = e.key;
      final row = e.value;
      return {
        'rank': (i + 1).toString(),
        'name': (row['user_name'] as String?) ?? 'User',
        'points': '${row['points'] ?? 0} points',
        'avatar': (row['user_avatar_url'] as String?) ?? '',
        'isTop': i == 0,
      };
    }).toList();
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
                  CircleAvatar(
                    backgroundImage: (entry['avatar']! as String).isNotEmpty
                        ? NetworkImage(entry['avatar']! as String)
                        : null,
                    child: (entry['avatar']! as String).isEmpty ? const Icon(Icons.person) : null,
                  ),
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