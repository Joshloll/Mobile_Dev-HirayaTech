import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class CommunityFeedPage extends StatefulWidget {
  const CommunityFeedPage({super.key});

  @override
  State<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage> {
  final List<Map<String, dynamic>> _posts = [
    {
      'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
      'name': 'Liam Carter',
      'time': '2d ago',
      'text': 'Just donated my old laptop to a local school here in Cagayan de Oro! Feels great to give back and reduce e-waste. #SustainableTech #CDO',
      'postImage': 'assets/images/mb.png',
      'likes': 23, 'comments': 2, 'shares': 2, 'isLiked': false,
    },
    {
      'avatar': 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=100',
      'name': 'Sophia Bennett',
      'time': '3d ago',
      'text': 'Traded my old phone for a refurbished one! Loving the new device and the eco-friendly choice. Highly recommend everyone to check out the marketplace.',
      'postImage': 'assets/images/ip16.png',
      'likes': 18, 'comments': 3, 'shares': 1, 'isLiked': false,
    },
  ];

  void _toggleLike(int index) {
    setState(() {
      final post = _posts[index];
      post['isLiked'] = !post['isLiked'];
      if (post['isLiked']) {
        post['likes']++;
      } else {
        post['likes']--;
      }
    });
  }

  void _showCommentSheet(BuildContext context, Map<String, dynamic> post) {
    // --- NEW: Realistic dummy comments ---
    final List<Map<String, String>> dummyComments = [
      {
        'name': 'Maria Dela Cruz',
        'avatarUrl': 'https://i.pravatar.cc/150?img=45',
        'commentText': 'Wow, that\'s so inspiring! Great job giving your laptop a second life.'
      },
      {
        'name': 'Juan Santos',
        'avatarUrl': 'https://i.pravatar.cc/150?img=32',
        'commentText': 'This is what sustainability is all about. Keep it up!'
      }
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center( child: Container( width: 40, height: 5, decoration: BoxDecoration( color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10), ), ), ),
                const SizedBox(height: 16),
                const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const Divider(),
                // --- MODIFIED: Uses the new dummyComments list ---
                Expanded(
                  child: ListView.separated(
                    itemCount: dummyComments.length,
                    itemBuilder: (ctx, i) {
                      final comment = dummyComments[i];
                      return ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage(comment['avatarUrl']!)),
                        title: Text(comment['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(comment['commentText']!),
                      );
                    },
                    separatorBuilder: (ctx, i) => const Divider(height: 1),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            filled: true,
                            fillColor: Color(0xFFF0F2F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF3A86FF)),
                        onPressed: () { /* TODO: Implement send comment logic */ },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _sharePost(Map<String, dynamic> post) {
    Share.share(
      'Check out this post from ${post['name']} on EcoWaste: \n\n"${post['text']}"',
      subject: 'A post from the EcoWaste Community',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(context, _posts[index], index);
      },
      separatorBuilder: (context, index) => Container(height: 8, color: Colors.grey.shade200),
    );
  }

  Widget _buildPostCard(BuildContext context, Map<String, dynamic> post, int index) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundImage: NetworkImage(post['avatar'])),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(post['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(post['time'], style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(post['text']),
                if (post['postImage'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(post['postImage']),
                    ),
                  ),
                const SizedBox(height: 12),
                _buildPostActions(context, post, index),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostActions(BuildContext context, Map<String, dynamic> post, int index) {
    final isLiked = post['isLiked'] as bool;

    Widget actionButton({ required IconData activeIcon, required IconData inactiveIcon, required bool isActive, required String count, required Color activeColor, required VoidCallback onPressed, }) {
      return TextButton.icon(
        onPressed: onPressed,
        icon: Icon( isActive ? activeIcon : inactiveIcon, size: 20, color: isActive ? activeColor : Colors.grey.shade600, ),
        label: Text(count, style: TextStyle(color: Colors.grey.shade700)),
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        actionButton(
          activeIcon: Icons.favorite,
          inactiveIcon: Icons.favorite_border,
          isActive: isLiked,
          activeColor: Colors.red,
          count: post['likes'].toString(),
          onPressed: () => _toggleLike(index),
        ),
        actionButton(
          activeIcon: Icons.chat_bubble,
          inactiveIcon: Icons.chat_bubble_outline,
          isActive: false,
          activeColor: Theme.of(context).primaryColor,
          count: post['comments'].toString(),
          onPressed: () => _showCommentSheet(context, post),
        ),
        actionButton(
          activeIcon: Icons.send,
          inactiveIcon: Icons.send_outlined,
          isActive: false,
          activeColor: Theme.of(context).primaryColor,
          count: post['shares'].toString(),
          onPressed: () => _sharePost(post),
        ),
      ],
    );
  }
}