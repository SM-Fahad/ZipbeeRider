import 'dart:io';
import 'package:ZipBee_Driver/features/auth/registration/controller/registration_controller.dart';
import 'package:ZipBee_Driver/features/auth/vehicle_details/screen/vehicle_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class IdentityCardController extends GetxController {
  final nidController = TextEditingController();
  final licenseController = TextEditingController();
  final selectedLicenseClass = ''.obs;

  final identityIssueDate = ''.obs;
  final drivingLicenseIssueDate = ''.obs;

  final frontIdCard = Rx<File?>(null);
  final backIdCard = Rx<File?>(null);
  final frontLicenseCard = Rx<File?>(null);
  final backLicenseCard = Rx<File?>(null);
  final licenseClassOptions = const [
    'Class 2B',
    'Class 2A',
    'Class 2',
    'Class 3',
    'Class 3A',
    'Class 4',
    'Class 5',
  ];

  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  Future<void> pickImage(Rx<File?> imageTarget) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSizeInBytes = await file.length();

      if (fileSizeInBytes > 5 * 1024 * 1024) {
        EasyLoading.showError("Image size must be under 5MB");
        return;
      }

      imageTarget.value = file;
    }
  }

  /// Remove selected image
  void removeImage(Rx<File?> imageTarget) {
    imageTarget.value = null;
  }

  void pickDate(BuildContext context, RxString target) async {
    final lastAllowedDate = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: lastAllowedDate,
      firstDate: DateTime(1980),
      lastDate: lastAllowedDate,
    );
    if (picked != null) {
      target.value = DateFormat('d/M/yyyy').format(picked);
    }
  }

  /// Continue button action
  void continueNext() {
    if (nidController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter NRIC number');
      return;
    }
    if (identityIssueDate.value.isEmpty) {
      EasyLoading.showError('Please select NRIC issue date');
      return;
    }
    if (frontIdCard.value == null) {
      EasyLoading.showError('Please upload NRIC front image');
      return;
    }
    if (backIdCard.value == null) {
      EasyLoading.showError('Please upload NRIC back image');
      return;
    }
    if (licenseController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter driving license number');
      return;
    }
    if (drivingLicenseIssueDate.value.isEmpty) {
      EasyLoading.showError('Please select driving license issue date');
      return;
    }
    if (selectedLicenseClass.value.isEmpty) {
      EasyLoading.showError('Please select license class');
      return;
    }
    if (frontLicenseCard.value == null) {
      EasyLoading.showError('Please upload driving license front image');
      return;
    }
    if (backLicenseCard.value == null) {
      EasyLoading.showError('Please upload driving license back image');
      return;
    }

    try {
      final selectedDate = DateFormat(
        'd/M/yyyy',
      ).parseStrict(identityIssueDate.value);
      final today = DateUtils.dateOnly(DateTime.now());
      if (selectedDate.isAfter(today)) {
        EasyLoading.showError(
          'NRIC issue date cannot be in the future',
        );
        return;
      }
    } catch (e) {
      EasyLoading.showError('Please select a valid NRIC issue date');
      return;
    }

    try {
      final selectedDate = DateFormat(
        'd/M/yyyy',
      ).parseStrict(drivingLicenseIssueDate.value);
      final today = DateUtils.dateOnly(DateTime.now());
      if (selectedDate.isAfter(today)) {
        EasyLoading.showError(
          'Driving license issue date cannot be in the future',
        );
        return;
      }
    } catch (e) {
      EasyLoading.showError('Please select a valid driving license issue date');
      return;
    }

    final regCtrl = Get.put(RegistrationController(), tag: 'registration');

    regCtrl.identityCardNumber.value = nidController.text.trim();
    regCtrl.nidFront.value = frontIdCard.value;
    regCtrl.nidBack.value = backIdCard.value;
    regCtrl.drivingLicenseNumber.value = licenseController.text.trim();
    regCtrl.licenseClass.value = selectedLicenseClass.value;

    if (identityIssueDate.value.isNotEmpty) {
      try {
        final d = DateFormat('d/M/yyyy').parseStrict(identityIssueDate.value);
        regCtrl.identityCardIssueDate.value = d.toIso8601String() + 'Z';
      } catch (e) {}
    }

    if (drivingLicenseIssueDate.value.isNotEmpty) {
      try {
        final d = DateFormat(
          'd/M/yyyy',
        ).parseStrict(drivingLicenseIssueDate.value);
        regCtrl.drivingLicenseIssueDate.value = d.toIso8601String() + 'Z';
      } catch (e) {}
    }

    regCtrl.dlFront.value = frontLicenseCard.value;
    regCtrl.dlBack.value = backLicenseCard.value;

    Get.to(VehicleDetailsScreen());
  }
}
