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
    // setEmail();
  }

  // void setEmail() async {
  //   final email = await SharedPreferencesHelper.getEmail();
  //   emailController.text = email ?? '';
  // }

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
    if (driverPhoto.value == null) {
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

    final regCtrl = Get.put(RegistrationController(), tag: 'registration');

    regCtrl.raiderName.value = driverNameController.text.trim();
    regCtrl.contactNumber.value =
        "${selectedCountryCode.value}${contactNumberController.text.trim()}";
    regCtrl.email.value = emailController.text.trim();
    regCtrl.dob.value = convertDobToIso(dobController.text);
    regCtrl.gender.value = selectedGender.value;

    if (driverPhoto.value != null) {
      regCtrl.driverPhotos.add(driverPhoto.value!);
    }

    regCtrl.emergencyContactName.value = emergencyContactNameController.text
        .trim();
    regCtrl.emergencyContactNumber.value =
        "${emergencySelectedCountryCode.value}${emergencyContactNumberController.text.trim()}";

    // Navigate to next screen
    Get.to(IdentityCardScreen());
  }
}
