// lib/services/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';

class AuthService {
  final _supabaseService = SupabaseService();

  // SIGN UP - Returns a String? with an error message, or null on success.
  Future<String?> createNewUser(String email, String password, {String? name}) async {
    return await _supabaseService.signUp(
      email: email,
      password: password,
      name: name ?? 'User',
    );
  }

  // SIGN IN - Returns a String? with an error message, or null on success.
  Future<String?> logInUser(String email, String password) async {
    return await _supabaseService.signIn(
      email: email,
      password: password,
    );
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _supabaseService.signOut();
  }

  // AUTH STATE STREAM (This is what your AuthWrapper or equivalent will use)
  Stream<User?> get user {
    return _supabaseService.authStateChanges.map((state) => state.session?.user);
  }

  // Get current user
  User? get currentUser => _supabaseService.currentUser;
}
