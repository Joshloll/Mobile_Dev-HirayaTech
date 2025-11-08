// lib/marketplace/messaging/chat_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobiledev_ecowaste/profile/public_profile_page.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _supabaseService = SupabaseService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _pendingImageUrl;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() { _isLoading = true; });
    
    final messages = await _supabaseService.getMessages(widget.conversationId);
    
    if (mounted) {
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _markMessagesAsRead() async {
    await _supabaseService.markMessagesAsRead(widget.conversationId);
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty && _pendingImageUrl == null) return;

    setState(() { _isSending = true; });

    final error = await _supabaseService.sendMessage(
      conversationId: widget.conversationId,
      content: content,
      recipientUserId: widget.otherUserId,
      imageUrl: _pendingImageUrl,
    );

    if (mounted) {
      setState(() { _isSending = false; });

      if (error == null) {
        _messageController.clear();
        _pendingImageUrl = null;
        await _loadMessages();
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _supabaseService.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfilePage(userId: widget.otherUserId)));
          },
          child: Row(
            children: [
              CircleAvatar(child: Text(widget.otherUserName.isNotEmpty ? widget.otherUserName[0].toUpperCase() : '?')),
              const SizedBox(width: 12),
              Expanded(child: Text(widget.otherUserName, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isSentByMe = message['sender_id'] == currentUserId;
                          final createdAt = message['created_at'] != null
                              ? DateTime.parse(message['created_at'] as String)
                              : null;

                          return _buildMessageBubble(
                            content: message['content'] as String? ?? '',
                            isSentByMe: isSentByMe,
                            timestamp: createdAt,
                            imageUrl: message['image_url'] as String?,
                          );
                        },
                      ),
          ),

          // Pending image preview (if any)
          if (_pendingImageUrl != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(_pendingImageUrl!, width: 60, height: 60, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Image attached', maxLines: 1, overflow: TextOverflow.ellipsis)),
                  IconButton(
                    tooltip: 'Remove',
                    onPressed: _isSending ? null : () => setState(() { _pendingImageUrl = null; }),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String content,
    required bool isSentByMe,
    DateTime? timestamp,
    String? imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSentByMe) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSentByMe 
                        ? const Color(0xFF3A86FF) 
                        : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isSentByMe ? 20 : 4),
                      bottomRight: Radius.circular(isSentByMe ? 4 : 20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null)
                        GestureDetector(
                          onTap: () => _showImagePreview(imageUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrl,
                              width: 220,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      if (content.isNotEmpty) ...[
                        if (imageUrl != null) const SizedBox(height: 8),
                        Text(
                          content,
                          style: TextStyle(
                            color: isSentByMe ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (timestamp != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isSentByMe) const SizedBox(width: 8),
        ],
      ),
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
            'No messages yet',
            style: GoogleFonts.splineSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation!',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
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
            IconButton(
              tooltip: 'Attach image',
              onPressed: _isSending ? null : _pickAndUploadImage,
              icon: const Icon(Icons.image_outlined),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: const Color(0xFF3A86FF),
              child: IconButton(
                onPressed: _isSending ? null : _sendMessage,
                icon: _isSending
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

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final ext = picked.name.contains('.') ? picked.name.split('.').last : 'jpg';
    final url = await _supabaseService.uploadChatImageBytes(bytes, fileExt: ext);
    if (url == null) return;
    setState(() { _pendingImageUrl = url; });
  }

  void _showImagePreview(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.network(url, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('h:mm a').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE h:mm a').format(dateTime);
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }
}

