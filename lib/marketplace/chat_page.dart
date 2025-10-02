// lib/marketplace/chat_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for the chat messages
    final List<Map<String, dynamic>> messages = [
      {'isMe': false, 'text': "Hey there! I'm interested in the iPhone 13 you listed. Could you tell me more about its condition?", 'time': '10:00 AM'},
      {'isMe': true, 'text': "Hi Liam, thanks for reaching out! The phone is in excellent condition, with no scratches. I've attached some photos for you to check out.", 'time': '10:01 AM', 'imageUrl': 'https://images.unsplash.com/photo-1633257348232-3ac58674aa2b?w=400'},
      {'isMe': false, 'text': "Thanks for the photos! It looks great. Does it come with the original box and accessories?", 'time': '10:02 AM'},
      {'isMe': true, 'text': "Yes, it does! Everything is included.", 'time': '10:03 AM'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 1,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1D3557),
      centerTitle: false,
      title: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100'),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Liam Harper',
                style: GoogleFonts.splineSans(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'Online',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final bool isMe = message['isMe'];
    final alignment = isMe ? MainAxisAlignment.end : MainAxisAlignment.start;
    final color = isMe ? const Color(0xFF3A86FF) : Colors.grey.shade200;
    final textColor = isMe ? Colors.white : Colors.black87;
    final borderRadius = isMe
        ? const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(16))
        : const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomRight: Radius.circular(16));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: alignment,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(color: color, borderRadius: borderRadius),
                  child: Text(message['text'], style: TextStyle(color: textColor)),
                ),
                if (message['imageUrl'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(message['imageUrl']),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(message['time'], style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(icon: Icon(Icons.add_photo_alternate_outlined, color: Colors.grey.shade600), onPressed: () {}),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Write a message...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF3A86FF),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}