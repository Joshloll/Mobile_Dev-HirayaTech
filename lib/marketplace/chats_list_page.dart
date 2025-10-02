// lib/marketplace/chats_list_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_page.dart'; // Import the individual chat page

class ChatsListPage extends StatelessWidget {
  const ChatsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for chat conversations
    final List<Map<String, dynamic>> purchaseChats = [
      {'name': 'Liam Carter', 'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100', 'device': 'iPhone 14 Pro Max', 'message': "Perfect! I'll take it.", 'time': '2d', 'unread': 1, 'isOnline': true},
      {'name': 'Sophia Bennett', 'avatar': 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=100', 'device': 'Galaxy S23 Ultra', 'message': "I'm interested in buying this device.", 'time': '1w', 'unread': 0, 'isOnline': false},
    ];

    final List<Map<String, dynamic>> listingChats = [
      {'name': 'Ava Thompson', 'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100', 'device': 'MacBook Pro 13"', 'message': "Is this still available?", 'time': '1d', 'unread': 0, 'isOnline': false},
      {'name': 'Noah Foster', 'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100', 'device': 'Apple Watch Series 8', 'message': "Can you do \$250?", 'time': '3d', 'unread': 3, 'isOnline': true},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D3557),
        centerTitle: true,
        title: Text('Chats', style: GoogleFonts.splineSans(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Chats from My Purchases/Interests'),
          ...purchaseChats.map((chat) => _buildChatTile(context, chat, isHighlighted: chat['unread'] > 0)).toList(),
          _buildSectionHeader('Chats for My Listings'),
          ...listingChats.map((chat) => _buildChatTile(context, chat, isHighlighted: chat['unread'] > 0)).toList(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
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

  Widget _buildChatTile(BuildContext context, Map<String, dynamic> chat, {bool isHighlighted = false}) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatPage()),
        );
      },
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(chat['avatar']),
          ),
          if (chat['isOnline'])
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                height: 14,
                width: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      tileColor: isHighlighted ? Colors.blue.shade50 : Colors.transparent,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(chat['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(chat['time'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(chat['device'], style: TextStyle(color: isHighlighted ? const Color(0xFF1D3557) : Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  chat['message'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: isHighlighted ? Colors.black87 : Colors.grey.shade600),
                ),
              ),
              if (chat['unread'] > 0)
                CircleAvatar(
                  radius: 10,
                  backgroundColor: const Color(0xFF3A86FF),
                  child: Text(
                    chat['unread'].toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}