class PostModel {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  // Optional aggregated fields from views
  final String? userName;
  final String? userAvatarUrl;
  final int? reactionCount;
  final int? commentCount;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.imageUrl,
    this.userName,
    this.userAvatarUrl,
    this.reactionCount,
    this.commentCount,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      content: map['content'] as String,
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      userName: map['user_name'] as String?,
      userAvatarUrl: map['user_avatar_url'] as String?,
      reactionCount: map['reaction_count'] as int?,
      commentCount: map['comment_count'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}


