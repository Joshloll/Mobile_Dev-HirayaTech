import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'create_account_page.dart';
import 'package:mobiledev_ecowaste/marketplace/marketplace_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              Center(
                child: Image.asset('assets/images/logo_leaf.png', height: 120),
              ),
              const SizedBox(height: 32),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Email or Username',
                  prefixIcon: Icon(Icons.mail_outline, color: Colors.grey.shade500),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade500),
                  suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
                ),
              ),
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Forgot Password?'))),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MarketplacePage()), (route) => false), child: const Text('Login'))),
              const SizedBox(height: 48),
              _buildDivider(),
              const SizedBox(height: 24),
              _buildSocialButtons(),
              const SizedBox(height: 48),
              _buildSignUpLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: Text.rich(
        TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
          children: [
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
              recognizer: TapGestureRecognizer()..onTap = () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CreateAccountPage())),
            ),
          ],
        ),
      ),
    );
  }

  // Unchanged helper widgets
  Widget _buildDivider() { return Row( children: [ Expanded(child: Divider(color: Colors.grey.shade300)), const Padding( padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('OR', style: TextStyle(color: Colors.grey)), ), Expanded(child: Divider(color: Colors.grey.shade300)), ], ); }
  Widget _buildSocialButtons() { Widget socialButton(String assetName, String label) { return OutlinedButton( onPressed: () {}, style: OutlinedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), ), child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [ Image.asset(assetName, height: 24, width: 24), const SizedBox(width: 10), Text("Continue with $label", style: const TextStyle( color: Colors.black87, fontWeight: FontWeight.w500)), ], ), ); } return Column( children: [ socialButton('assets/images/google_logo.png', 'Google'), const SizedBox(height: 16), socialButton('assets/images/apple_logo.png', 'Apple'), const SizedBox(height: 16), socialButton('assets/images/facebook_logo.png', 'Facebook'), ], ); }
}