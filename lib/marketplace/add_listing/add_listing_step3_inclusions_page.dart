import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show File;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'listing_form_provider.dart';
import 'add_listing_step4_photos_page.dart';
import 'widgets/verification_card.dart';

class AddListingStep3InclusionsPage extends StatelessWidget {
  const AddListingStep3InclusionsPage({super.key});

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
                    Text('Inclusions & History', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    _buildInclusionsCard(context, form),
                    _buildHistoryCard(context, form),
                    const SizedBox(height: 16),
                    _buildConditionCard(context, form),
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

  Widget _attachRow(
    BuildContext context, {
    required bool isVideo,
    required bool hasFile,
    required VoidCallback onAttach,
    required VoidCallback onRemove,
    required VoidCallback onView,
    String? filename,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(isVideo ? Icons.videocam_outlined : Icons.photo_camera_outlined, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              filename == null ? (hasFile ? 'Attachment' : 'No attachment') : filename,
              style: TextStyle(color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.add_circle_outline, size: 16),
            label: const Text('Attach'),
            onPressed: onAttach,
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
          ),
          const SizedBox(width: 8),
          if (hasFile)
            TextButton(onPressed: onView, child: const Text('View')),
          if (hasFile)
            IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_outline, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildInclusionsCard(BuildContext context, ListingFormProvider form) {
    return VerificationCard(
      title: "What's Included?",
      children: [
        CheckboxListTile(
          title: const Text('Original Box'),
          value: form.includedAccessories.contains('Original Box'),
          onChanged: (val) => form.updateAccessories('Original Box', val!),
          activeColor: Theme.of(context).colorScheme.primary,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('Charger & Cable'),
          value: form.includedAccessories.contains('Charger & Cable'),
          onChanged: (val) => form.updateAccessories('Charger & Cable', val!),
          activeColor: Theme.of(context).colorScheme.primary,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildHistoryCard(BuildContext context, ListingFormProvider form) {
    return VerificationCard(
      title: 'Device History',
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Repair History", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              onChanged: form.updateRepairHistory,
              decoration: const InputDecoration(hintText: 'e.g., Screen replaced once, battery original'),
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
              maxLines: 3,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildConditionCard(BuildContext context, ListingFormProvider form) {
    return VerificationCard(
      title: 'Condition & Verification',
      children: [
        SwitchListTile(
          title: const Text('Powers on correctly?'),
          value: form.powersOnCorrectly ?? false,
          onChanged: (v) => form.updatePowersOn(v),
          activeColor: Theme.of(context).colorScheme.primary,
          contentPadding: EdgeInsets.zero,
        ),
        _attachRow(
          context,
          isVideo: true,
          hasFile: form.powersOnProofVideo != null,
          onAttach: form.pickPowersOnProofVideo,
          onRemove: form.removePowersOnProofVideo,
          onView: () => _previewVideo(context, form.powersOnProofVideo),
          filename: form.powersOnProofVideo?.name,
        ),
        SwitchListTile(
          title: const Text('Buttons functional?'),
          value: form.buttonsFunctional ?? false,
          onChanged: (v) => form.updateButtonsFunctional(v),
          activeColor: Theme.of(context).colorScheme.primary,
          contentPadding: EdgeInsets.zero,
        ),
        _attachRow(
          context,
          isVideo: true,
          hasFile: form.buttonsFunctionalProofVideo != null,
          onAttach: form.pickButtonsFunctionalProofVideo,
          onRemove: form.removeButtonsFunctionalProofVideo,
          onView: () => _previewVideo(context, form.buttonsFunctionalProofVideo),
          filename: form.buttonsFunctionalProofVideo?.name,
        ),
        const SizedBox(height: 8),
        const Text('Battery life estimate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          onChanged: form.updateBatteryLife,
          decoration: const InputDecoration(hintText: 'e.g., 85% or ~5 hours'),
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Battery drains fast?'),
          value: form.batteryDrainsFast ?? false,
          onChanged: (v) => form.updateBatteryDrain(v),
          activeColor: Theme.of(context).colorScheme.primary,
          contentPadding: EdgeInsets.zero,
        ),
        _attachRow(
          context,
          isVideo: false,
          hasFile: form.batteryDrainsFastProofPhoto != null,
          onAttach: form.pickBatteryDrainsFastProofPhoto,
          onRemove: form.removeBatteryDrainsFastProofPhoto,
          onView: () => _previewBattery(context, form.batteryDrainsFastProofPhoto),
          filename: form.batteryDrainsFastProofPhoto?.name,
        ),
        SwitchListTile(
          title: const Text('Screen has damage?'),
          value: form.screenHasDamage ?? false,
          onChanged: (v) => form.updateScreenDamage(v),
          activeColor: Theme.of(context).colorScheme.primary,
          contentPadding: EdgeInsets.zero,
        ),
        _attachRow(
          context,
          isVideo: false,
          hasFile: form.screenDamageProofPhoto != null,
          onAttach: form.pickScreenDamageProofPhoto,
          onRemove: form.removeScreenDamageProofPhoto,
          onView: () => _previewBattery(context, form.screenDamageProofPhoto),
          filename: form.screenDamageProofPhoto?.name,
        ),
        SwitchListTile(
          title: const Text('Touchscreen responsive?'),
          value: form.touchscreenResponsive ?? false,
          onChanged: (v) => form.updateTouchscreen(v),
          activeColor: Theme.of(context).colorScheme.primary,
          contentPadding: EdgeInsets.zero,
        ),
        _attachRow(
          context,
          isVideo: true,
          hasFile: form.touchscreenResponsiveProofVideo != null,
          onAttach: form.pickTouchscreenResponsiveProofVideo,
          onRemove: form.removeTouchscreenResponsiveProofVideo,
          onView: () => _previewVideo(context, form.touchscreenResponsiveProofVideo),
          filename: form.touchscreenResponsiveProofVideo?.name,
        ),
      ],
    );
  }

  void _previewBattery(BuildContext context, XFile? file) {
    final x = file;
    if (x == null) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: kIsWeb
            ? Image.network(x.path, fit: BoxFit.contain)
            : Image.file(File(x.path), fit: BoxFit.contain),
      ),
    );
  }

  void _previewVideo(BuildContext context, XFile? file) {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video preview not available on web.')));
      return;
    }
    final x = file;
    if (x == null) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.videocam_outlined, size: 48),
              SizedBox(height: 8),
              Text('Video selected. Preview plays on the Review page or mobile.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: ElevatedButton(
        onPressed: () {
          final form = Provider.of<ListingFormProvider>(context, listen: false);
          form.nextStep();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: form,
                child: const AddListingStep4PhotosPage(),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          minimumSize: const Size(double.infinity, 50),
          shape: const StadiumBorder(),
        ),
        child: const Text('Next'),
      ),
    );
  }
}
