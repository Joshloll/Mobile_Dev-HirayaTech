import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D3557),
        centerTitle: true,
        title: Text('Help & Support', style: GoogleFonts.splineSans(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 24),
          _buildSectionHeader('Support Topics'),
          _buildSupportTile(icon: Icons.person_outline, title: 'Account Management'),
          _buildSupportTile(icon: Icons.sync_alt, title: 'Selling/Trading Devices'),
          _buildSupportTile(icon: Icons.volunteer_activism_outlined, title: 'Donation Process'),
          _buildSupportTile(icon: Icons.groups_outlined, title: 'Community Guidelines'),
          const SizedBox(height: 24),
          _buildSectionHeader('Contact Us'),
          _buildSupportTile(icon: Icons.chat_bubble_outline, title: 'Message Us'),
          _buildSupportTile(icon: Icons.mail_outline, title: 'Email Support'),
          _buildSupportTile(icon: Icons.call_outlined, title: 'Phone Support'),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search FAQs',
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
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

  Widget _buildSupportTile({required IconData icon, required String title}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        onTap: () {},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.grey.shade100,
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          foregroundColor: const Color(0xFF3A86FF),
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}