import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/models/user_model.dart';
import 'package:mobiledev_ecowaste/profile/edit_profile_page.dart';
import 'package:mobiledev_ecowaste/settings/settings_page.dart';
import 'package:mobiledev_ecowaste/support/help_support_page.dart';
import 'package:mobiledev_ecowaste/recycling_finder/recycling_finder_page.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _supabaseService = SupabaseService();
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _supabaseService.currentUser;
    if (user != null) {
      final profileData = await _supabaseService.getUserProfile(user.id);
      if (profileData != null && mounted) {
        setState(() {
          _userProfile = UserProfile.fromJson(profileData);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _supabaseService.signOut();
      // The AuthWrapper will automatically handle navigation to login screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.edit_outlined,
                  text: 'Edit Profile',
                  onTap: () async {
                    Navigator.of(context).pop();
                    final result = await Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const EditProfilePage())
                    );
                    // Reload profile if edit was successful
                    if (result == true) {
                      _loadUserProfile();
                    }
                  },
                ),
                _buildDrawerItem(
                    icon: Icons.recycling_outlined,
                    text: 'Find Recycling Centers',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RecyclingFinderPage()));
                    }),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  text: 'Help & Support',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportPage()));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  text: 'Settings',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            text: 'Logout',
            onTap: () {
              Navigator.of(context).pop();
              _handleLogout();
            },
            color: Colors.red.shade700,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1D3557),
      ),
      child: _isLoading
          ? const Column(
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 12),
                Text('Loading...', style: TextStyle(color: Colors.white)),
              ],
            )
          : Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundImage: (_userProfile?.avatarUrl ?? '').isNotEmpty
                      ? NetworkImage(_userProfile!.avatarUrl)
                      : null,
                  child: (_userProfile?.avatarUrl ?? '').isEmpty ? const Icon(Icons.person, color: Colors.white, size: 44) : null,
                ),
                const SizedBox(height: 12),
                Text(
                  _userProfile?.name ?? 'User',
                  style: GoogleFonts.splineSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfilePage()),
                    );
                    if (result == true) {
                      _loadUserProfile();
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1D3557),
                    minimumSize: const Size(160, 36),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF1D3557)),
      title: Text(
        text,
        style: TextStyle(
          color: color ?? Colors.grey.shade800,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}