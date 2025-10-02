import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'listing_form_provider.dart';
import 'add_listing_step3_page.dart';

import 'widgets/modern_segmented_control.dart';
import 'widgets/verification_card.dart';
import 'widgets/radio_question.dart';
import 'widgets/proof_requirement.dart';
import 'widgets/thousands_formatter.dart';

class AddListingStep2Page extends StatefulWidget {
  const AddListingStep2Page({super.key});

  @override
  State<AddListingStep2Page> createState() => _AddListingStep2PageState();
}

class _AddListingStep2PageState extends State<AddListingStep2Page> {
  late final TextEditingController _priceController;
  late final TextEditingController _tradeController;
  late final TextEditingController _repairHistoryController;
  late final TextEditingController _batteryLifeController;

  @override
  void initState() {
    super.initState();
    final formProvider = Provider.of<ListingFormProvider>(context, listen: false);
    final initialPrice = formProvider.price != null ? NumberFormat('#,###').format(formProvider.price) : '';
    _priceController = TextEditingController(text: initialPrice);
    _tradeController = TextEditingController(text: formProvider.tradeDetails ?? '');
    _repairHistoryController = TextEditingController(text: formProvider.repairHistory ?? '');
    _batteryLifeController = TextEditingController(text: formProvider.batteryLifeEstimate ?? '');
  }

  @override
  void dispose() {
    _priceController.dispose();
    _tradeController.dispose();
    _repairHistoryController.dispose();
    _batteryLifeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListingFormProvider>(
      builder: (context, formProvider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('List Your Device')),
          body: Column(
            children: [
              const LinearProgressIndicator(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    Text('Listing Details', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    ModernSegmentedControl(
                      groupValue: formProvider.listingType,
                      onValueChanged: (type) => formProvider.updateListingType(type),
                      isEnabled: !formProvider.isTypeLocked,
                    ),
                    const SizedBox(height: 24),
                    if (formProvider.listingType == ListingType.sell) _buildSellFields(formProvider),
                    if (formProvider.listingType == ListingType.trade) _buildTradeFields(formProvider),
                    if (formProvider.listingType == ListingType.donate) _buildDonateFields(),
                    const SizedBox(height: 24),
                    _buildInclusionsCard(formProvider),
                    _buildHistoryCard(formProvider),
                    const SizedBox(height: 24),
                    Text('Device Photos', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Add general photos of your device from all angles.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                    const SizedBox(height: 16),
                    _buildPhotoGrid(context, formProvider),
                    const SizedBox(height: 24),
                    Text('Verification Questionnaire', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildVerificationCards(formProvider),
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

  Widget _buildSellFields(ListingFormProvider formProvider) {
    return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text("Price (in PHP)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)), const SizedBox(height: 8), TextField( controller: _priceController, onChanged: (val) => formProvider.updatePrice(val), keyboardType: TextInputType.number, inputFormatters: [ FilteringTextInputFormatter.digitsOnly, ThousandsSeparatorInputFormatter(), ], decoration: const InputDecoration(hintText: 'Enter your selling price'), style: TextStyle(color: Theme.of(context).colorScheme.primary), ), ], );
  }

  Widget _buildTradeFields(ListingFormProvider formProvider) {
    return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text("Desired Device for Trade", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)), const SizedBox(height: 8), TextField( controller: _tradeController, onChanged: (val) => formProvider.updateTradeDetails(val), decoration: const InputDecoration(hintText: 'e.g., iPhone 15, MacBook Air M2'), style: TextStyle(color: Theme.of(context).colorScheme.primary), autocorrect: false, enableSuggestions: false, ), ], );
  }

  Widget _buildInclusionsCard(ListingFormProvider formProvider) {
    return VerificationCard( title: "What's Included?", children: [ CheckboxListTile( title: const Text('Original Box'), value: formProvider.includedAccessories.contains('Original Box'), onChanged: (val) => formProvider.updateAccessories('Original Box', val!), activeColor: Theme.of(context).colorScheme.primary, controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero, ), CheckboxListTile( title: const Text('Charger & Cable'), value: formProvider.includedAccessories.contains('Charger & Cable'), onChanged: (val) => formProvider.updateAccessories('Charger & Cable', val!), activeColor: Theme.of(context).colorScheme.primary, controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero, ), ], );
  }

  Widget _buildHistoryCard(ListingFormProvider formProvider) {
    return VerificationCard( title: 'Device History', children: [ Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text("Repair History", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)), const SizedBox(height: 8), TextField( controller: _repairHistoryController, onChanged: (val) => formProvider.updateRepairHistory(val), decoration: const InputDecoration(hintText: 'e.g., Screen replaced once, battery original'), style: TextStyle(color: Theme.of(context).colorScheme.primary), ), ], ) ], );
  }

  Widget _buildVerificationCards(ListingFormProvider formProvider) {
    return Column(
      children: [
        VerificationCard( title: 'Functionality', children: [ RadioQuestion( question: 'Does the device power on correctly?', groupValue: formProvider.powersOnCorrectly, onChanged: (val) => formProvider.updatePowersOn(val), ), RadioQuestion( question: 'Are all buttons and ports functional?', groupValue: formProvider.buttonsFunctional, onChanged: (val) => formProvider.updateButtonsFunctional(val), ), ProofRequirement( icon: Icons.videocam_outlined, title: 'Proof Required: Video', subtitle: 'Show the device powering on and testing each button/port.', onUpload: () => formProvider.pickFunctionalityVideoProof(), onClear: () => formProvider.removeFunctionalityVideoProof(), hasProof: formProvider.functionalityVideoProof != null, ) ], ),
        VerificationCard( title: 'Battery Health', children: [ Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text("How long does the battery last on a full charge?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)), const SizedBox(height: 8), TextField( controller: _batteryLifeController, onChanged: (val) => formProvider.updateBatteryLife(val), decoration: const InputDecoration(hintText: 'e.g., about 8 hours'), style: TextStyle(color: Theme.of(context).colorScheme.primary), ), ], ), const SizedBox(height: 16), RadioQuestion( question: 'Does the battery drain unusually fast?', groupValue: formProvider.batteryDrainsFast, onChanged: (val) => formProvider.updateBatteryDrain(val), ), ProofRequirement( icon: Icons.photo_camera_outlined, title: 'Proof Required: Photo', subtitle: 'Take a picture of the battery health screen in settings.', onUpload: () => formProvider.pickBatteryPhotoProof(), onClear: () => formProvider.removeBatteryPhotoProof(), hasProof: formProvider.batteryPhotoProof != null, ), ], ),
        VerificationCard( title: 'Screen Condition', children: [ RadioQuestion( question: 'Are there any cracks, dead pixels, or discoloration?', groupValue: formProvider.screenHasDamage, onChanged: (val) => formProvider.updateScreenDamage(val), ), RadioQuestion( question: 'Is the touchscreen fully responsive?', groupValue: formProvider.touchscreenResponsive, onChanged: (val) => formProvider.updateTouchscreen(val), ) ], ),
      ],
    );
  }

  Widget _buildPhotoGrid(BuildContext context, ListingFormProvider formProvider) { return GridView.builder( shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: formProvider.devicePhotos.length + 1, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16, ), itemBuilder: (context, index) { if (index == formProvider.devicePhotos.length) { return GestureDetector( onTap: () => formProvider.pickDevicePhotos(), child: Container( decoration: BoxDecoration( color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12), ), child: Icon(Icons.photo_camera_outlined, color: Theme.of(context).colorScheme.primary, size: 32), ), ); } final photo = formProvider.devicePhotos[index]; return Stack( clipBehavior: Clip.none, children: [ Container( decoration: BoxDecoration( borderRadius: BorderRadius.circular(12), image: DecorationImage( image: FileImage(File(photo.path)), fit: BoxFit.cover, ), ), ), Positioned( top: -8, right: -8, child: GestureDetector( onTap: () => formProvider.removeDevicePhoto(photo), child: Container( decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.cancel, color: Colors.red, size: 24), ), ), ), ], ); }, ); }
  Widget _buildDonateFields() { return Card( color: Colors.blue.shade50, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding( padding: const EdgeInsets.all(12.0), child: Text( 'Thank you for your generosity! Your donation will help bridge the digital divide.', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.primary), ), ), ); }

  Widget _buildNextButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: ElevatedButton(
        onPressed: () {
          final formProvider = Provider.of<ListingFormProvider>(context, listen: false);
          formProvider.nextStep();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: formProvider,
                child: const AddListingStep3Page(),
              ),
            ),
          );
        },
        child: const Text('Proceed to Review'),
      ),
    );
  }
}