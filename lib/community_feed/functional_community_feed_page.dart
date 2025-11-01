// lib/community_feed/functional_community_feed_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';
import 'package:mobiledev_ecowaste/community_feed/create_post/functional_create_post_page.dart';
import 'package:mobiledev_ecowaste/community_feed/post_details_page.dart';
import 'package:mobiledev_ecowaste/profile/public_profile_page.dart';
import 'package:intl/intl.dart';

class FunctionalCommunityFeedPage extends StatefulWidget {
  const FunctionalCommunityFeedPage({super.key});

  @override
  State<FunctionalCommunityFeedPage> createState() => _FunctionalCommunityFeedPageState();
}

class _FunctionalCommunityFeedPageState extends State<FunctionalCommunityFeedPage> {
  final _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() { _isLoading = true; });

    final posts = await _supabaseService.getAllPosts();

    if (mounted) {
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleReaction(String postId) async {
    await _supabaseService.addReaction(
      postId: postId,
      reactionType: 'like',
    );
    _loadPosts(); // Refresh to update counts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: _posts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        return _buildPostCard(_posts[index]);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FunctionalCreatePostPage(),
            ),
          );
          if (result == true) {
            _loadPosts();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final userName = post['user_name'] as String? ?? 'Unknown User';
    final userAvatar = post['user_avatar_url'] as String?;
    final content = post['content'] as String;
    final imageUrl = post['image_url'] as String?;
    final reactionCount = post['reaction_count'] ?? 0;
    final commentCount = post['comment_count'] ?? 0;
    final createdAt = post['created_at'] != null
        ? DateTime.parse(post['created_at'] as String)
        : null;
    final userId = post['user_id'] as String;
    final postId = post['id'] as String;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info header
          ListTile(
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PublicProfilePage(userId: userId),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: userAvatar != null
                    ? NetworkImage(userAvatar)
                    : null,
                child: userAvatar == null ? const Icon(Icons.person) : null,
              ),
            ),
            title: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PublicProfilePage(userId: userId),
                  ),
                );
              },
              child: Text(
                userName,
                style: GoogleFonts.splineSans(fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: createdAt != null
                ? Text(_formatTime(createdAt))
                : null,
          ),

          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          // Image if exists
          if (imageUrl != null)
            Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 50),
                );
              },
            ),

          // Reaction and comment counts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (reactionCount > 0)
                  Text(
                    '$reactionCount ${reactionCount == 1 ? 'like' : 'likes'}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                const Spacer(),
                if (commentCount > 0)
                  Text(
                    '$commentCount ${commentCount == 1 ? 'comment' : 'comments'}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _toggleReaction(postId),
                  icon: const Icon(Icons.thumb_up_outlined),
                  label: const Text('Like'),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailsPage(post: post),
                      ),
                    );
                  },
                  icon: const Icon(Icons.comment_outlined),
                  label: const Text('Comment'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: GoogleFonts.splineSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share something!',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return '1d ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}

