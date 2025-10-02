import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/models/user_model.dart';
import 'package:mobiledev_ecowaste/profile/edit_profile_page.dart';
import 'package:mobiledev_ecowaste/settings/settings_page.dart';
import 'package:mobiledev_ecowaste/support/help_support_page.dart';
import 'package:mobiledev_ecowaste/recycling_finder/recycling_finder_page.dart'; // <-- NEW IMPORT

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

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
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
                  },
                ),
                // --- THIS ITEM IS NOW FUNCTIONAL ---
                _buildDrawerItem(
                    icon: Icons.recycling_outlined,
                    text: 'Find Recycling Centers',
                    onTap: () {
                      Navigator.of(context).pop(); // Close the drawer first
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
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(currentUser.avatarUrl),
          ),
          const SizedBox(height: 12),
          Text(
            currentUser.name,
            style: GoogleFonts.splineSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentUser.email,
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
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