// lib/settings/settings_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/profile/edit_profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _generalNotifications = true;
  bool _communityInteractions = false;
  bool _appUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D3557),
        centerTitle: true,
        title: Text('Settings', style: GoogleFonts.splineSans(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Profile Settings'),
          _buildNavigationTile(
            context: context,
            title: 'Edit Profile',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Notifications'),
          _buildSwitchTile(
            title: 'General Notifications',
            subtitle: 'Updates about listings, messages, and more.',
            value: _generalNotifications,
            onChanged: (val) => setState(() => _generalNotifications = val),
          ),
          _buildSwitchTile(
            title: 'Community Interactions',
            subtitle: 'Notifications on post interactions.',
            value: _communityInteractions,
            onChanged: (val) => setState(() => _communityInteractions = val),
          ),
          _buildSwitchTile(
            title: 'App Updates',
            subtitle: 'Alerts about new features and updates.',
            value: _appUpdates,
            onChanged: (val) => setState(() => _appUpdates = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        title,
        style: GoogleFonts.splineSans(
          color: const Color(0xFF1D3557),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildNavigationTile({required BuildContext context, required String title, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.grey.shade100,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF3A86FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.grey.shade100,
      ),
    );
  }
}