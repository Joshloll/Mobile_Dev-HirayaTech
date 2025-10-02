// lib/models/user_model.dart

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

// This is our single source of user data for the whole app.
// In a real app, this would be loaded after the user logs in.
const User currentUser = User(
  name: 'Ethan Carter',
  email: 'ethan.carter@email.com',
  avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
);