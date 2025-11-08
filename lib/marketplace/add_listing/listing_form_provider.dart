import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum ListingType { sell, trade, donate }

class ListingFormProvider with ChangeNotifier {
  int _currentStep = 1;
  final int _totalSteps = 5; // 1. Info -> 2. Type & Commercials -> 3. Inclusions & History -> 4. Photos & Verification -> 5. Review

  final bool isTypeLocked;

  // Step 1 Data
  String? deviceType;
  String? brand;
  String? model;
  String? storageCapacity;
  String? color;

  // Step 2 Data
  String? title;
  String? description;
  ListingType listingType;
  double? price;
  String? tradeDetails;

  // Step 3 Data
  List<String> includedAccessories = [];
  String? repairHistory;

  // Verification Properties
  bool? powersOnCorrectly;
  bool? buttonsFunctional;
  String? batteryLifeEstimate;
  bool? batteryDrainsFast;
  bool? screenHasDamage;
  bool? touchscreenResponsive;

  // Proof Uploads
  List<XFile> devicePhotos = [];
  XFile? functionalityVideoProof;
  XFile? batteryPhotoProof;

  // Per-question attachments (new)
  XFile? powersOnProofVideo;
  XFile? buttonsFunctionalProofVideo;
  XFile? batteryDrainsFastProofPhoto;
  XFile? screenDamageProofPhoto;
  XFile? touchscreenResponsiveProofVideo;

  ListingFormProvider({ListingType? initialListingType})
      : listingType = initialListingType ?? ListingType.sell,
        isTypeLocked = initialListingType != null;

  int get currentStep => _currentStep;
  int get totalSteps => _totalSteps;
  double get progress => _currentStep / _totalSteps;

  void updateTitle(String value) { title = value; notifyListeners(); }
  void updateDescription(String value) { description = value; notifyListeners(); }

  void updateDeviceType(String? value) { deviceType = value; notifyListeners(); }
  void updateBrand(String? value) { brand = value; notifyListeners(); }
  void updateModel(String? value) { model = value; notifyListeners(); }
  void updateStorageCapacity(String value) { storageCapacity = value; notifyListeners(); }
  void updateColor(String value) { color = value; notifyListeners(); }

  void updateListingType(ListingType type) { if (!isTypeLocked) { listingType = type; notifyListeners(); } }
  void updatePrice(String value) { final sanitizedValue = value.replaceAll(',', ''); price = double.tryParse(sanitizedValue); notifyListeners(); }
  void updateTradeDetails(String value) { tradeDetails = value; notifyListeners(); }
  void updateAccessories(String accessory, bool isIncluded) {
    if (isIncluded) {
      if (!includedAccessories.contains(accessory)) { includedAccessories.add(accessory); }
    } else {
      includedAccessories.remove(accessory);
    }
    notifyListeners();
  }
  void updateRepairHistory(String value) { repairHistory = value; notifyListeners(); }

  void updatePowersOn(bool? value) { powersOnCorrectly = value; notifyListeners(); }
  void updateButtonsFunctional(bool? value) { buttonsFunctional = value; notifyListeners(); }
  void updateBatteryLife(String value) { batteryLifeEstimate = value; notifyListeners(); }
  void updateBatteryDrain(bool? value) { batteryDrainsFast = value; notifyListeners(); }
  void updateScreenDamage(bool? value) { screenHasDamage = value; notifyListeners(); }
  void updateTouchscreen(bool? value) { touchscreenResponsive = value; notifyListeners(); }

  Future<void> pickDevicePhotos() async { final ImagePicker picker = ImagePicker(); final List<XFile> images = await picker.pickMultiImage(imageQuality: 70); devicePhotos.addAll(images); notifyListeners(); }
  void removeDevicePhoto(XFile photo) { devicePhotos.remove(photo); notifyListeners(); }

  Future<void> pickFunctionalityVideoProof() async { final ImagePicker picker = ImagePicker(); functionalityVideoProof = await picker.pickVideo(source: ImageSource.camera); notifyListeners(); }
  void removeFunctionalityVideoProof() { functionalityVideoProof = null; notifyListeners(); }

  Future<void> pickBatteryPhotoProof() async { final ImagePicker picker = ImagePicker(); batteryPhotoProof = await picker.pickImage(source: ImageSource.camera, imageQuality: 70); notifyListeners(); }
  void removeBatteryPhotoProof() { batteryPhotoProof = null; notifyListeners(); }

  // New per-question pick/remove helpers
  Future<void> pickPowersOnProofVideo() async { final ImagePicker picker = ImagePicker(); powersOnProofVideo = await picker.pickVideo(source: ImageSource.camera); notifyListeners(); }
  void removePowersOnProofVideo() { powersOnProofVideo = null; notifyListeners(); }

  Future<void> pickButtonsFunctionalProofVideo() async { final ImagePicker picker = ImagePicker(); buttonsFunctionalProofVideo = await picker.pickVideo(source: ImageSource.camera); notifyListeners(); }
  void removeButtonsFunctionalProofVideo() { buttonsFunctionalProofVideo = null; notifyListeners(); }

  Future<void> pickBatteryDrainsFastProofPhoto() async { final ImagePicker picker = ImagePicker(); batteryDrainsFastProofPhoto = await picker.pickImage(source: ImageSource.camera, imageQuality: 70); notifyListeners(); }
  void removeBatteryDrainsFastProofPhoto() { batteryDrainsFastProofPhoto = null; notifyListeners(); }

  Future<void> pickScreenDamageProofPhoto() async { final ImagePicker picker = ImagePicker(); screenDamageProofPhoto = await picker.pickImage(source: ImageSource.camera, imageQuality: 70); notifyListeners(); }
  void removeScreenDamageProofPhoto() { screenDamageProofPhoto = null; notifyListeners(); }

  Future<void> pickTouchscreenResponsiveProofVideo() async { final ImagePicker picker = ImagePicker(); touchscreenResponsiveProofVideo = await picker.pickVideo(source: ImageSource.camera); notifyListeners(); }
  void removeTouchscreenResponsiveProofVideo() { touchscreenResponsiveProofVideo = null; notifyListeners(); }

  void nextStep() { if (_currentStep < _totalSteps) { _currentStep++; notifyListeners(); } }
  void previousStep() { if (_currentStep > 1) { _currentStep--; notifyListeners(); } }
}