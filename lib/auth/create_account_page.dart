// lib/auth/create_account_page.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobiledev_ecowaste/services/auth_service.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});
  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Passwords do not match."),
        ),
      );
      return;
    }

    // Check if email is entered
    if (_emailController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please enter an email address."),
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });

    final email = _emailController.text.trim();
    final username = _usernameController.text.trim().isNotEmpty
        ? _usernameController.text.trim()
        : email.split('@').first;

    final result = await _authService.createNewUser(
      email,
      _passwordController.text.trim(),
      name: username,
    );

    if (mounted) {
      setState(() { _isLoading = false; });
    }

    if (result != null) {
      // An error occurred, show the message from the service
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(result)),
      );
    } else {
      // Success! Show a success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
          content: Text("Account successfully created, please log in now"),
        ),
      );
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return;
      Navigator.of(context).pop();
    }
    // On success, your AuthWrapper handles navigation automatically.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: Image.asset('assets/images/logo_leaf.png', height: 120),
              ),
              const SizedBox(height: 32),
              _buildTextField(label: 'Username', placeholder: 'Choose a username', controller: _usernameController),
              const SizedBox(height: 24),
              _buildTextField(label: 'Email', placeholder: 'Enter your email', controller: _emailController),
              const SizedBox(height: 24),
              _buildPasswordField(controller: _passwordController),
              const SizedBox(height: 24),
              _buildTextField(label: 'Confirm Password', placeholder: 'Confirm your password', isPassword: true, controller: _confirmPasswordController),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createAccount,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Account'),
                ),
              ),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 24),
              _buildSocialButtons(),
              const SizedBox(height: 32),
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets from your code ---
  Widget _buildTextField({required String label, required String placeholder, required TextEditingController controller, bool isPassword = false}) { return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(label, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 16)), const SizedBox(height: 8), TextField(controller: controller, obscureText: isPassword, decoration: InputDecoration(hintText: placeholder)), ], ); }
  Widget _buildPasswordField({required TextEditingController controller}) { return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text('Password', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 16)), const SizedBox(height: 8), TextField( controller: controller, obscureText: !_isPasswordVisible, decoration: InputDecoration( hintText: 'Create a password', suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)), ), ), ], ); }
  Widget _buildLoginLink() { return Center( child: Text.rich( TextSpan( text: 'Already have an account? ', style: TextStyle(color: Colors.grey.shade700, fontSize: 16), children: [ TextSpan( text: 'Log In', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16), recognizer: TapGestureRecognizer()..onTap = () => Navigator.of(context).pop(), ), ], ), ), ); }
  Widget _buildDivider() { return Row( children: [ Expanded(child: Divider(color: Colors.grey.shade300)), const Padding( padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Or sign up with', style: TextStyle(color: Colors.grey)), ), Expanded(child: Divider(color: Colors.grey.shade300)), ], ); }
  Widget _buildSocialButtons() { Widget socialButton(String assetName, String label) { return Expanded( child: OutlinedButton( onPressed: () {}, style: OutlinedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), ), child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [ Image.asset(assetName, height: 22, width: 22), const SizedBox(width: 8), Text( label, style: const TextStyle( color: Colors.black87, fontWeight: FontWeight.bold), ), ], ), ), ); } return Row( children: [ socialButton('assets/images/google_logo.png', 'Google'), const SizedBox(width: 16), socialButton('assets/images/apple_logo.png', 'Apple'), const SizedBox(width: 16), socialButton('assets/images/facebook_logo.png', 'Facebook'), ], ); }
}
