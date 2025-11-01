// lib/auth/sign_in_page.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobiledev_ecowaste/services/auth_service.dart';
import 'package:mobiledev_ecowaste/auth/create_account_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // All your fields and controllers remain the same...
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // The sign-in logic
  Future<void> _signIn() async {
    setState(() { _isLoading = true; });

    // ==========================================================
    // --- THIS LINE IS NOW UPDATED ---
    final String? errorMessage = await _authService.logInUser( // <-- USE THE RENAMED METHOD
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    // ==========================================================

    if (mounted) {
      setState(() { _isLoading = false; });
    }

    if (errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Your entire UI build method remains exactly the same.
    // I am including it here for completeness.
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: Image.asset('assets/images/logo_leaf.png', height: 120),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                  label: 'Email',
                  placeholder: 'Enter your email',
                  controller: _emailController),
              const SizedBox(height: 24),
              _buildPasswordField(controller: _passwordController),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 24),
              _buildSocialButtons(),
              const SizedBox(height: 32),
              _buildSignUpLink(),
            ],
          ),
        ),
      ),
    );
  }

  // --- All your helper widgets remain unchanged ---
  Widget _buildTextField({required String label, required String placeholder, required TextEditingController controller}) { return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(label, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 16)), const SizedBox(height: 8), TextField( controller: controller, decoration: InputDecoration(hintText: placeholder), ), ], ); }
  Widget _buildPasswordField({required TextEditingController controller}) { return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text('Password', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 16)), const SizedBox(height: 8), TextField( controller: controller, obscureText: !_isPasswordVisible, decoration: InputDecoration( hintText: 'Enter your password', suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)), ), ), ], ); }
  Widget _buildSignUpLink() { return Center( child: Text.rich( TextSpan( text: "Don't have an account? ", style: TextStyle(color: Colors.grey.shade700, fontSize: 16), children: [ TextSpan( text: 'Sign Up', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16), recognizer: TapGestureRecognizer() ..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateAccountPage())), ), ], ), ), ); }
  Widget _buildDivider() { return Row( children: [ Expanded(child: Divider(color: Colors.grey.shade300)), const Padding( padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Or sign in with', style: TextStyle(color: Colors.grey)), ), Expanded(child: Divider(color: Colors.grey.shade300)), ], ); }
  Widget _buildSocialButtons() { Widget socialButton(String assetName, String label) { return Expanded( child: OutlinedButton( onPressed: () {}, style: OutlinedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), ), child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [ Image.asset(assetName, height: 22, width: 22), const SizedBox(width: 8), Text( label, style: const TextStyle( color: Colors.black87, fontWeight: FontWeight.bold), ), ], ), ), ); } return Row( children: [ socialButton('assets/images/google_logo.png', 'Google'), const SizedBox(width: 16), socialButton('assets/images/apple_logo.png', 'Apple'), const SizedBox(width: 16), socialButton('assets/images/facebook_logo.png', 'Facebook'), ], ); }
}
