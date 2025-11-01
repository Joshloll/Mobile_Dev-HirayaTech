import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiledev_ecowaste/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _newsletterEnabled = false;
  bool _isLoading = true;
  bool _isSaving = false;

  // Controllers to manage the text in the TextFields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  final _supabaseService = SupabaseService();
  UserProfile? _userProfile;
  File? _selectedImage;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _supabaseService.currentUser;
    if (user != null) {
      final profileData = await _supabaseService.getUserProfile(user.id);
      if (profileData != null && mounted) {
        setState(() {
          _userProfile = UserProfile.fromJson(profileData);
          _nameController.text = _userProfile!.name;
          _emailController.text = _userProfile!.email;
          _phoneController.text = _userProfile!.phoneNumber ?? '';
          _currentAvatarUrl = _userProfile!.avatarUrl;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_userProfile == null) return;

    setState(() { _isSaving = true; });

    String? newAvatarUrl;
    
    // Upload new image if selected
    if (_selectedImage != null) {
      newAvatarUrl = await _supabaseService.uploadProfileImage(
        _userProfile!.id,
        _selectedImage!,
      );
    }

    // Update profile
    final error = await _supabaseService.updateUserProfile(
      userId: _userProfile!.id,
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isNotEmpty 
          ? _phoneController.text.trim() 
          : null,
      avatarUrl: newAvatarUrl,
    );

    if (mounted) {
      setState(() { _isSaving = false; });

      if (error == null) {
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
            content: Text('Error: $error'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
                  _buildProfilePhotoSection(),
                  const SizedBox(height: 32),
                  _buildTextField(label: 'Name', controller: _nameController),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'Email', controller: _emailController),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'Phone Number', placeholder: 'Enter your phone number', controller: _phoneController),
                  const SizedBox(height: 24),
                  _buildChangePasswordButton(),
                  const SizedBox(height: 32),
                  _buildCommunicationPreferences(),
                ],
              ),
            ),
          ),
          _buildFooterButtons(),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    ImageProvider imageProvider;
    
    if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    } else if (_currentAvatarUrl != null) {
      imageProvider = NetworkImage(_currentAvatarUrl!);
    } else {
      imageProvider = const NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200');
    }

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 64,
                backgroundImage: imageProvider,
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.4),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 32),
                    onPressed: _pickImage,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _pickImage,
            child: const Text('Change Profile Photo', style: TextStyle(color: Color(0xFF3A86FF))),
          ),
        ],
      ),
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

  Widget _buildChangePasswordButton() {
    return ListTile(
      onTap: () {},
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.grey.shade100,
      title: const Text('Change Password'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  Widget _buildCommunicationPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Communication Preferences',
          style: GoogleFonts.splineSans(
            color: const Color(0xFF1D3557),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Newsletter'),
          subtitle: Text('Receive updates and offers', style: TextStyle(color: Colors.grey.shade600)),
          value: _newsletterEnabled,
          onChanged: (bool value) {
            setState(() {
              _newsletterEnabled = value;
            });
          },
          activeColor: const Color(0xFF3A86FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: Colors.grey.shade100,
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