import 'package:flutter/material.dart';

class AddListingConfirmationPage extends StatelessWidget {
  const AddListingConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade50,
                ),
                child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
              ),
              const SizedBox(height: 32),
              Text(
                  'Your Listing is Live!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 16),
              Text(
                'Your device is now visible on the marketplace. You will be notified when you receive messages or offers.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('View My Listings'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Return to Marketplace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}