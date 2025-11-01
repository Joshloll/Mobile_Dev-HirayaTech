// lib/community_feed/post_details_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';
import 'package:mobiledev_ecowaste/profile/public_profile_page.dart';
import 'package:intl/intl.dart';

class PostDetailsPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailsPage({super.key, required this.post});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final _supabaseService = SupabaseService();
  final _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoadingComments = true;
  bool _isPostingComment = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() { _isLoadingComments = true; });

    final comments = await _supabaseService.getPostComments(widget.post['id'] as String);

    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() { _isPostingComment = true; });

    final error = await _supabaseService.addComment(
      postId: widget.post['id'] as String,
      content: content,
    );

    if (mounted) {
      setState(() { _isPostingComment = false; });

      if (error == null) {
        _commentController.clear();
        _loadComments();
        FocusScope.of(context).unfocus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error: $error'),
          ),
        );
      }
    }
  }

  Future<void> _toggleLike() async {
    await _supabaseService.addReaction(
      postId: widget.post['id'] as String,
      reactionType: 'like',
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.post['user_name'] as String? ?? 'Unknown User';
    final userAvatar = widget.post['user_avatar_url'] as String?;
    final content = widget.post['content'] as String;
    final imageUrl = widget.post['image_url'] as String?;
    final createdAt = widget.post['created_at'] != null
        ? DateTime.parse(widget.post['created_at'] as String)
        : null;
    final userId = widget.post['user_id'] as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original post
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User info
                        Row(
                          children: [
                            GestureDetector(
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
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
                                      style: GoogleFonts.splineSans(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (createdAt != null)
                                    Text(
                                      _formatTime(createdAt),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Post content
                        Text(
                          content,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),

                        // Image if exists
                        if (imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Like button
                        OutlinedButton.icon(
                          onPressed: _toggleLike,
                          icon: const Icon(Icons.thumb_up_outlined),
                          label: const Text('Like'),
                        ),
                      ],
                    ),
                  ),

                  const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

                  // Comments section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Comments',
                      style: GoogleFonts.splineSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Comments list
                  if (_isLoadingComments)
                    const Center(child: CircularProgressIndicator())
                  else if (_comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No comments yet.\nBe the first to comment!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        return _buildCommentTile(_comments[index]);
                      },
                    ),
                ],
              ),
            ),
          ),

          // Comment input
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentTile(Map<String, dynamic> comment) {
    final userName = comment['user_name'] as String? ?? 'Unknown User';
    final userAvatar = comment['user_avatar_url'] as String?;
    final content = comment['content'] as String;
    final createdAt = comment['created_at'] != null
        ? DateTime.parse(comment['created_at'] as String)
        : null;
    final userId = comment['user_id'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PublicProfilePage(userId: userId),
                ),
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: userAvatar != null ? NetworkImage(userAvatar) : null,
              child: userAvatar == null ? const Icon(Icons.person, size: 20) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
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
                      style: GoogleFonts.splineSans(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(content),
                  const SizedBox(height: 4),
                  if (createdAt != null)
                    Text(
                      _formatTime(createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: const Color(0xFF3A86FF),
              child: IconButton(
                onPressed: _isPostingComment ? null : _postComment,
                icon: _isPostingComment
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
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

