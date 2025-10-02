import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_account_page.dart';
import 'sign_in_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: _buildTopSection(context),
            ),
          ),
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 384,
          width: double.infinity,
          child: Image.asset('assets/images/devices.png', fit: BoxFit.cover),
        ),
        Container(
          height: 384,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ Colors.transparent, Colors.white.withOpacity(0.8), Colors.white ],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, 152),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Text(
                  'Manage Your Devices Sustainably',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.splineSans(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    'Sell, trade, or donate your electronics. Earn points for eco-friendly actions and join a community committed to sustainability.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.splineSans( color: Colors.grey.shade700, fontSize: 16 ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 180, 24, 48),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateAccountPage())),
              style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
              child: const Text('Get Started'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInPage())),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: const StadiumBorder()),
              child: const Text('I already have an account'),
            ),
          ),
        ],
      ),
    );
  }
}