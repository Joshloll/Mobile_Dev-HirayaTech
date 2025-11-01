// lib/services/supabase_service.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Get Supabase client
  SupabaseClient get client => Supabase.instance.client;

  // Get current user
  User? get currentUser => client.auth.currentUser;

  // Auth state stream
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // SIGN UP - Creates a new user and their profile
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create auth user
      final response = await client.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.user == null) {
        return 'Failed to create account. Please try again.';
      }

      // Create user profile in the database
      await client.from('profiles').insert({
        'id': response.user!.id,
        'email': email.trim(),
        'name': name.trim(),
        'avatar_url': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
        'created_at': DateTime.now().toIso8601String(),
      });

      return null; // Success
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        return 'An account already exists for that email.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // SIGN IN
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Success
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        return 'Incorrect email or password. Please try again.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // GET USER PROFILE
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // UPDATE USER PROFILE
  Future<String?> updateUserProfile({
    required String userId,
    String? name,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await client
          .from('profiles')
          .update(updates)
          .eq('id', userId);

      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  // UPLOAD PROFILE IMAGE
  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'profile_images/$fileName';

      // Upload file to Supabase Storage
      await client.storage.from('avatars').upload(
        filePath,
        imageFile,
        fileOptions: const FileOptions(upsert: true),
      );

      // Get public URL
      final publicUrl = client.storage.from('avatars').getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // STREAM USER PROFILE (real-time updates)
  Stream<Map<String, dynamic>?> streamUserProfile(String userId) {
    return client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) => data.isNotEmpty ? data.first : null);
  }

  // ============================================
  // LISTINGS METHODS
  // ============================================

  // CREATE LISTING
  Future<String?> createListing({
    required String listingType, // 'sell', 'trade', 'donate'
    required String title,
    required String description,
    List<String>? imageUrls,
    double? price,
    String? tradeDetails,
    String? deviceType,
    String? brand,
    String? model,
  }) async {
    try {
      final user = currentUser;
      if (user == null) return 'User not authenticated';

      await client.from('listings').insert({
        'user_id': user.id,
        'listing_type': listingType,
        'title': title,
        'description': description,
        'image_urls': imageUrls,
        'price': price,
        'trade_details': tradeDetails,
        'device_type': deviceType,
        'brand': brand,
        'model': model,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      });

      return null; // Success
    } catch (e) {
      print('Error creating listing: $e');
      return e.toString();
    }
  }

  // UPLOAD LISTING IMAGE
  Future<String?> uploadListingImage(File imageFile) async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final fileExt = imageFile.path.split('.').last;
      final fileName = '${user.id}-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'listings/$fileName';

      await client.storage.from('listing_images').upload(
        filePath,
        imageFile,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl = client.storage.from('listing_images').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Error uploading listing image: $e');
      return null;
    }
  }

  // GET ALL LISTINGS
  Future<List<Map<String, dynamic>>> getAllListings() async {
    try {
      final response = await client
          .from('listings_with_users')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching listings: $e');
      return [];
    }
  }

  // GET LISTINGS BY TYPE
  Future<List<Map<String, dynamic>>> getListingsByType(String type) async {
    try {
      final response = await client
          .from('listings_with_users')
          .select()
          .eq('listing_type', type)
          .eq('status', 'active')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching listings: $e');
      return [];
    }
  }

  // GET USER'S LISTINGS
  Future<List<Map<String, dynamic>>> getUserListings(String userId) async {
    try {
      final response = await client
          .from('listings')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching user listings: $e');
      return [];
    }
  }

  // STREAM LISTINGS (real-time updates)
  Stream<List<Map<String, dynamic>>> streamListings() {
    return client
        .from('listings_with_users')
        .stream(primaryKey: ['id'])
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // ============================================
  // MESSAGING METHODS
  // ============================================

  // GET OR CREATE CONVERSATION
  Future<String?> getOrCreateConversation(String otherUserId, {String? listingId}) async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response = await client.rpc('get_or_create_conversation', params: {
        'p_user1_id': user.id,
        'p_user2_id': otherUserId,
        'p_listing_id': listingId,
      });

      return response.toString();
    } catch (e) {
      print('Error getting/creating conversation: $e');
      return null;
    }
  }

  // GET USER'S CONVERSATIONS
  Future<List<Map<String, dynamic>>> getUserConversations() async {
    try {
      final user = currentUser;
      if (user == null) return [];

      final response = await client
          .from('conversations_with_details')
          .select()
          .or('user1_id.eq.${user.id},user2_id.eq.${user.id}')
          .order('last_message_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  // GET MESSAGES IN CONVERSATION
  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    try {
      final response = await client
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  // SEND MESSAGE
  Future<String?> sendMessage({
    required String conversationId,
    required String content,
    String? imageUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) return 'User not authenticated';

      await client.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': user.id,
        'content': content,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      return null; // Success
    } catch (e) {
      print('Error sending message: $e');
      return e.toString();
    }
  }

  // STREAM MESSAGES (real-time updates)
  Stream<List<Map<String, dynamic>>> streamMessages(String conversationId) {
    return client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // MARK MESSAGES AS READ
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      final user = currentUser;
      if (user == null) return;

      await client
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', user.id);
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // ============================================
  // COMMUNITY POSTS METHODS
  // ============================================

  // CREATE POST
  Future<String?> createCommunityPost({
    required String content,
    String? imageUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) return 'User not authenticated';

      await client.from('community_posts').insert({
        'user_id': user.id,
        'content': content,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      return null; // Success
    } catch (e) {
      print('Error creating post: $e');
      return e.toString();
    }
  }

  // UPLOAD POST IMAGE
  Future<String?> uploadPostImage(File imageFile) async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final fileExt = imageFile.path.split('.').last;
      final fileName = '${user.id}-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'posts/$fileName';

      await client.storage.from('community_posts').upload(
        filePath,
        imageFile,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl = client.storage.from('community_posts').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Error uploading post image: $e');
      return null;
    }
  }

  // GET ALL POSTS
  Future<List<Map<String, dynamic>>> getAllPosts() async {
    try {
      final response = await client
          .from('community_posts_with_details')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  // GET USER'S POSTS
  Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
    try {
      final response = await client
          .from('community_posts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching user posts: $e');
      return [];
    }
  }

  // STREAM POSTS (real-time updates)
  Stream<List<Map<String, dynamic>>> streamPosts() {
    return client
        .from('community_posts_with_details')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // ADD REACTION
  Future<String?> addReaction({
    required String postId,
    required String reactionType, // 'like', 'love', 'care', 'wow', 'sad', 'angry'
  }) async {
    try {
      final user = currentUser;
      if (user == null) return 'User not authenticated';

      await client.from('post_reactions').upsert({
        'post_id': postId,
        'user_id': user.id,
        'reaction_type': reactionType,
        'created_at': DateTime.now().toIso8601String(),
      });

      return null; // Success
    } catch (e) {
      print('Error adding reaction: $e');
      return e.toString();
    }
  }

  // REMOVE REACTION
  Future<String?> removeReaction(String postId) async {
    try {
      final user = currentUser;
      if (user == null) return 'User not authenticated';

      await client
          .from('post_reactions')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', user.id);

      return null; // Success
    } catch (e) {
      print('Error removing reaction: $e');
      return e.toString();
    }
  }

  // GET POST REACTIONS
  Future<List<Map<String, dynamic>>> getPostReactions(String postId) async {
    try {
      final response = await client
          .from('post_reactions')
          .select()
          .eq('post_id', postId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching reactions: $e');
      return [];
    }
  }

  // ADD COMMENT
  Future<String?> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      final user = currentUser;
      if (user == null) return 'User not authenticated';

      await client.from('post_comments').insert({
        'post_id': postId,
        'user_id': user.id,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      });

      return null; // Success
    } catch (e) {
      print('Error adding comment: $e');
      return e.toString();
    }
  }

  // GET POST COMMENTS
  Future<List<Map<String, dynamic>>> getPostComments(String postId) async {
    try {
      final response = await client
          .from('post_comments_with_users')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  // GET USER TRANSACTIONS
  Future<List<Map<String, dynamic>>> getUserTransactions(String userId) async {
    try {
      final response = await client
          .from('user_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching user transactions: $e');
      return [];
    }
  }
}

