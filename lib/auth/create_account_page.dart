import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobiledev_ecowaste/marketplace/marketplace_page.dart';
import 'package:mobiledev_ecowaste/theme.dart';
import 'sign_in_page.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});
  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  bool _isPasswordVisible = false;

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
              _buildTextField(label: 'Email', placeholder: 'Enter your email'),
              const SizedBox(height: 24),
              _buildPasswordField(),
              const SizedBox(height: 24),
              _buildTextField(label: 'Confirm Password', placeholder: 'Confirm your password', isPassword: true),
              _buildPasswordMatchIndicator(),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MarketplacePage()), (route) => false), child: const Text('Create Account'))),
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

  Widget _buildTextField({required String label, required String placeholder, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(obscureText: isPassword, decoration: InputDecoration(hintText: placeholder)),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: 'Create a password',
            suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            child: LinearProgressIndicator(value: 0.66),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Text.rich(
        TextSpan(
          text: 'Already have an account? ',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
          children: [
            TextSpan(
              text: 'Log In',
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
              recognizer: TapGestureRecognizer()..onTap = () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInPage())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordMatchIndicator() { return Padding( padding: const EdgeInsets.only(top: 8.0), child: Row( children: [ Icon(Icons.check_circle, color: Colors.green.shade600, size: 20), const SizedBox(width: 4), Text( 'Passwords match', style: TextStyle(color: Colors.green.shade600, fontSize: 14), ), ], ), ); }
  Widget _buildDivider() { return Row( children: [ Expanded(child: Divider(color: Colors.grey.shade300)), const Padding( padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Or sign up with', style: TextStyle(color: Colors.grey)), ), Expanded(child: Divider(color: Colors.grey.shade300)), ], ); }
  Widget _buildSocialButtons() { Widget socialButton(String assetName, String label) { return Expanded( child: OutlinedButton( onPressed: () {}, style: OutlinedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), ), child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [ Image.asset(assetName, height: 22, width: 22), const SizedBox(width: 8), Text( label, style: const TextStyle( color: Colors.black87, fontWeight: FontWeight.bold), ), ], ), ), ); } return Row( children: [ socialButton('assets/images/google_logo.png', 'Google'), const SizedBox(width: 16), socialButton('assets/images/apple_logo.png', 'Apple'), const SizedBox(width: 16), socialButton('assets/images/facebook_logo.png', 'Facebook'), ], ); }
}