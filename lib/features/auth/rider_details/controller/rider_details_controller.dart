import 'dart:io';
// import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/auth/identity_card/screen/identity_card_screen.dart';
import 'package:ZipBee_Driver/features/auth/registration/controller/registration_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class RiderDetailsController extends GetxController {
  final driverNameController = TextEditingController();
  final contactNumberController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  final emergencyContactNameController = TextEditingController();
  final emergencyContactNumberController = TextEditingController();

  var selectedGender = ''.obs;
  final selectedCountryCode = '+65'.obs;
  final emergencySelectedCountryCode = '+65'.obs;
  var driverPhoto = Rx<File?>(null);
  var existingDriverPhotoUrl = ''.obs;

  final ImagePicker picker = ImagePicker();

  @override
  void onClose() {
    driverNameController.dispose();
    contactNumberController.dispose();
    emailController.dispose();
    dobController.dispose();
    emergencyContactNameController.dispose();
    emergencyContactNumberController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _checkAndPrefill();
  }

  void _checkAndPrefill() {
    if (Get.isRegistered<RegistrationController>(tag: 'registration')) {
      final regCtrl = Get.find<RegistrationController>(tag: 'registration');
      if (regCtrl.raiderName.value.isNotEmpty) {
        driverNameController.text = regCtrl.raiderName.value;
      }
      if (regCtrl.contactNumber.value.isNotEmpty) {
        final phone = regCtrl.contactNumber.value;
        if (phone.startsWith('+65')) {
          selectedCountryCode.value = '+65';
          contactNumberController.text = phone.substring(3);
        } else {
          contactNumberController.text = phone;
        }
      }
      if (regCtrl.email.value.isNotEmpty) {
        emailController.text = regCtrl.email.value;
      }
      if (regCtrl.dob.value.isNotEmpty) {
        dobController.text = _formatIsoToDisplay(regCtrl.dob.value);
      }
      if (regCtrl.gender.value.isNotEmpty) {
        final g = regCtrl.gender.value.trim().toUpperCase();
        if (g == 'MALE') {
          selectedGender.value = 'Male';
        } else if (g == 'FEMALE') {
          selectedGender.value = 'Female';
        } else {
          selectedGender.value = 'Other';
        }
      }
      if (regCtrl.emergencyContactName.value.isNotEmpty) {
        emergencyContactNameController.text =
            regCtrl.emergencyContactName.value;
      }
      if (regCtrl.emergencyContactNumber.value.isNotEmpty) {
        final ePhone = regCtrl.emergencyContactNumber.value;
        if (ePhone.startsWith('+65')) {
          emergencySelectedCountryCode.value = '+65';
          emergencyContactNumberController.text = ePhone.substring(3);
        } else {
          emergencyContactNumberController.text = ePhone;
        }
      }
      if (regCtrl.driverPhotos.isNotEmpty) {
        driverPhoto.value = regCtrl.driverPhotos.first;
      } else if (regCtrl.existingDriverPhotos.isNotEmpty) {
        existingDriverPhotoUrl.value = regCtrl.existingDriverPhotos.first;
      }
    }
  }

  String _formatIsoToDisplay(String raw) {
    if (raw.trim().isEmpty) return '';
    try {
      final date = DateTime.parse(raw.trim());
      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      try {
        if (raw.contains('T')) {
          final part = raw.split('T')[0];
          final parts = part.split('-');
          if (parts.length == 3) {
            return "${int.parse(parts[2])}/${int.parse(parts[1])}/${parts[0]}";
          }
        }
      } catch (_) {}
      return raw;
    }
  }

  Future<void> pickDriverPhoto() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      driverPhoto.value = File(pickedFile.path);
    }
  }

  /// Convert dd/MM/yyyy → ISO-8601 DateTime format (yyyy-MM-ddT00:00:00.000Z)
  String convertDobToIso(String input) {
    try {
      DateTime date = DateFormat("d/M/yyyy").parse(input);
      // Return full ISO-8601 format with Z at the end
      return date.toIso8601String() + 'Z';
    } catch (e) {
      return "";
    }
  }

  Future<void> submitRiderDetails() async {
    if (driverNameController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter your name');
      return;
    }
    if (contactNumberController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter mobile number');
      return;
    }
    if (emailController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter email address');
      return;
    }
    if (dobController.text.trim().isEmpty) {
      EasyLoading.showError('Please select date of birth');
      return;
    }
    if (selectedGender.value.isEmpty) {
      EasyLoading.showError('Please select gender');
      return;
    }
    if (driverPhoto.value == null && existingDriverPhotoUrl.value.isEmpty) {
      EasyLoading.showError('Please upload profile photo');
      return;
    }
    if (emergencyContactNameController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter emergency contact name');
      return;
    }
    if (emergencyContactNumberController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter emergency mobile number');
      return;
    }

    final regCtrl = Get.isRegistered<RegistrationController>(tag: 'registration')
        ? Get.find<RegistrationController>(tag: 'registration')
        : Get.put(RegistrationController(), tag: 'registration');

    regCtrl.raiderName.value = driverNameController.text.trim();
    regCtrl.contactNumber.value =
        "${selectedCountryCode.value}${contactNumberController.text.trim()}";
    regCtrl.email.value = emailController.text.trim();
    regCtrl.dob.value = convertDobToIso(dobController.text);
    regCtrl.gender.value = selectedGender.value;

    if (driverPhoto.value != null) {
      regCtrl.driverPhotos.assignAll([driverPhoto.value!]);
    } else if (existingDriverPhotoUrl.value.isNotEmpty) {
      regCtrl.existingDriverPhotos.assignAll([existingDriverPhotoUrl.value]);
    }

    regCtrl.emergencyContactName.value = emergencyContactNameController.text
        .trim();
    regCtrl.emergencyContactNumber.value =
        "${emergencySelectedCountryCode.value}${emergencyContactNumberController.text.trim()}";

    // Navigate to next screen
    Get.to(() => IdentityCardScreen());
  }
}
