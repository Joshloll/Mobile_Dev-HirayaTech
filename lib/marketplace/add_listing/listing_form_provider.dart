import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum ListingType { sell, trade, donate }

class ListingFormProvider with ChangeNotifier {
  int _currentStep = 1;
  final int _totalSteps = 3; // 1. Info -> 2. Details & Uploads -> 3. Review

  final bool isTypeLocked;

  // Step 1 Data
  String? deviceType;
  String? brand;
  String? model;
  String? storageCapacity;
  String? color;

  // Step 2 Data
  ListingType listingType;
  double? price;
  String? tradeDetails;
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

  ListingFormProvider({ListingType? initialListingType})
      : listingType = initialListingType ?? ListingType.sell,
        isTypeLocked = initialListingType != null;

  int get currentStep => _currentStep;
  int get totalSteps => _totalSteps;
  double get progress => _currentStep / _totalSteps;

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

  void nextStep() { if (_currentStep < _totalSteps) { _currentStep++; notifyListeners(); } }
  void previousStep() { if (_currentStep > 1) { _currentStep--; notifyListeners(); } }
}