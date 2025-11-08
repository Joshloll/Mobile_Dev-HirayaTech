import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'listing_form_provider.dart';
import 'add_listing_step3_page.dart';

class AddListingStep4PhotosPage extends StatelessWidget {
  const AddListingStep4PhotosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ListingFormProvider>(
      builder: (context, form, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('List Your Device')),
          body: Column(
            children: [
              LinearProgressIndicator(value: form.progress),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    Text('Photos & Verification', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Add general photos of your device from all angles.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                    const SizedBox(height: 16),
                    _buildPhotoGrid(context, form),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: form.pickDevicePhotos,
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('Add Photos'),
                        style: TextButton.styleFrom(
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Keep radio/verification on previous step or review; optional to add here later
                  ],
                ),
              ),
              _buildNextButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoGrid(BuildContext context, ListingFormProvider form) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: form.devicePhotos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final photo = form.devicePhotos[index];
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: kIsWeb
                      ? NetworkImage(photo.path) as ImageProvider
                      : FileImage(File(photo.path)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: -8,
              right: -8,
              child: GestureDetector(
                onTap: () => form.removeDevicePhoto(photo),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.cancel, color: Colors.red, size: 24),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: ElevatedButton(
        onPressed: () {
          final form = Provider.of<ListingFormProvider>(context, listen: false);
          if (form.devicePhotos.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one photo.')));
            return;
          }
          form.nextStep();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: form,
                child: const AddListingStep3Page(),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          minimumSize: const Size(double.infinity, 50),
          shape: const StadiumBorder(),
        ),
        child: const Text('Proceed to Review'),
      ),
    );
  }
}
