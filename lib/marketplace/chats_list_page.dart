// lib/marketplace/chats_list_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';
import 'package:mobiledev_ecowaste/marketplace/messaging/chat_page.dart';
import 'package:intl/intl.dart';

class ChatsListPage extends StatefulWidget {
  const ChatsListPage({super.key});

  @override
  State<ChatsListPage> createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  final _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() { _isLoading = true; });

    final conversations = await _supabaseService.getUserConversations();

    if (mounted) {
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D3557),
        centerTitle: true,
        title: Text('Chats', style: GoogleFonts.splineSans(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              await showSearch(
                context: context,
                delegate: _UserSearchDelegate(_supabaseService, onSelect: (user) async {
                  final conversationId = await _supabaseService.getOrCreateConversation(user['id'] as String);
                  if (!mounted) return;
                  if (conversationId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          conversationId: conversationId,
                          otherUserId: user['id'] as String,
                          otherUserName: (user['name'] as String?) ?? 'User',
                        ),
                      ),
                    );
                  }
                }),
              );
              _loadConversations();
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      return _buildChatTile(_conversations[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> conversation) {
    final currentUserId = _supabaseService.currentUser?.id;
    
    // Determine which user is the "other" user
    final isUser1 = conversation['user1_id'] == currentUserId;
    final otherUserId = isUser1 ? conversation['user2_id'] : conversation['user1_id'];
    final otherUserName = isUser1 ? conversation['user2_name'] : conversation['user1_name'];
    final otherUserAvatar = isUser1 ? conversation['user2_avatar_url'] : conversation['user1_avatar_url'];
    
    final lastMessage = conversation['last_message_content'] as String?;
    final lastMessageAt = conversation['last_message_at'] != null
        ? DateTime.parse(conversation['last_message_at'] as String)
        : null;

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              conversationId: (conversation['id']).toString(),
              otherUserId: otherUserId.toString(),
              otherUserName: (otherUserName is String) ? otherUserName : 'Unknown User',
            ),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: otherUserAvatar != null 
            ? NetworkImage(otherUserAvatar as String) 
            : null,
        child: otherUserAvatar == null ? const Icon(Icons.person) : null,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              (otherUserName is String) ? otherUserName : 'Unknown User',
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (lastMessageAt != null)
            Text(
              _formatTime(lastMessageAt),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
        ],
      ),
      subtitle: lastMessage != null
          ? Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: GoogleFonts.splineSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation by messaging\nsomeone on a listing',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (difference.inDays == 1) {
      return '1d';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}

class _UserSearchDelegate extends SearchDelegate {
  final SupabaseService _supabaseService;
  final void Function(Map<String, dynamic> user) onSelect;

  _UserSearchDelegate(this._supabaseService, {required this.onSelect});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text('Search users by name'));
    }
    return _buildResults();
  }

  Widget _buildResults() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _supabaseService.searchUsers(query.trim()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = snapshot.data!;
        if (results.isEmpty) {
          return const Center(child: Text('No users found'));
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final user = results[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: (user['avatar_url'] as String?) != null
                    ? NetworkImage(user['avatar_url'] as String)
                    : null,
                child: (user['avatar_url'] as String?) == null ? const Icon(Icons.person) : null,
              ),
              title: Text((user['name'] as String?) ?? 'User'),
              subtitle: Text((user['email'] as String?) ?? ''),
              onTap: () {
                onSelect(user);
                close(context, null);
              },
            );
          },
        );
      },
    );
  }
}
