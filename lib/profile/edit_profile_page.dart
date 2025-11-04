import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/models/user_model.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _isLoading = true;
  bool _isSaving = false;

  // Controllers to manage the text in the TextFields
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  final _supabaseService = SupabaseService();
  UserProfile? _userProfile;
  // Note: avatar editing is disabled per requirements

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _supabaseService.currentUser;
    if (user != null) {
      final profileData = await _supabaseService.getUserProfile(user.id);
      if (!mounted) return;
      if (profileData != null) {
        setState(() {
          _userProfile = UserProfile.fromJson(profileData);
          _nameController.text = _userProfile!.name;
          _isLoading = false;
        });
      } else {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_userProfile == null) return;

    setState(() { _isSaving = true; });

    // Update profile
    final error = await _supabaseService.updateUserProfile(
      userId: _userProfile!.id,
      name: _nameController.text.trim(),
    );

    // Optional: update password
    String? pwError;
    final newPw = _passwordController.text.trim();
    final confirmPw = _confirmPasswordController.text.trim();
    if (newPw.isNotEmpty || confirmPw.isNotEmpty) {
      if (newPw.length < 6) {
        pwError = 'Password must be at least 6 characters';
      } else if (newPw != confirmPw) {
        pwError = 'Passwords do not match';
      } else {
        pwError = await _supabaseService.updatePassword(newPw);
      }
    }

    if (mounted) {
      setState(() { _isSaving = false; });

      if (error == null && pwError == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Profile updated successfully!'),
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error: ${error ?? pwError}'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1D3557),
          centerTitle: true,
          title: Text('Edit Profile', style: GoogleFonts.splineSans(fontWeight: FontWeight.bold)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D3557),
        centerTitle: true,
        title: Text('Edit Profile', style: GoogleFonts.splineSans(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(label: 'Username', controller: _nameController),
                  const SizedBox(height: 16),
                  _buildPasswordFields(),
                ],
              ),
            ),
          ),
          _buildFooterButtons(),
        ],
      ),
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Change Password (optional)', style: GoogleFonts.splineSans(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildTextField(label: 'New Password', controller: _passwordController, placeholder: 'Enter new password'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Confirm Password', controller: _confirmPasswordController, placeholder: 'Re-enter new password'),
      ],
    );
  }

  Widget _buildTextField({required String label, String? placeholder, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.splineSans(color: const Color(0xFF1D3557), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3A86FF), width: 2),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildFooterButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1D3557),
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                textStyle: GoogleFonts.splineSans(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A86FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                textStyle: GoogleFonts.splineSans(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              child: _isSaving 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}