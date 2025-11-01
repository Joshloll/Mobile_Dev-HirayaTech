// lib/models/user_model.dart

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.phoneNumber,
    required this.createdAt,
    this.updatedAt,
  });

  // Create UserProfile from Supabase JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String? ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      phoneNumber: json['phone_number'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  // Convert UserProfile to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Deprecated: Keep for backward compatibility but not used
class User {
  final String name;
  final String email;
  final String avatarUrl;

  const User({
    required this.name,
    required this.email,
    required this.avatarUrl,
  });
}

// This is deprecated - use UserProfile from Supabase instead
const User currentUser = User(
  name: 'Ethan Carter',
  email: 'ethan.carter@email.com',
  avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
);
