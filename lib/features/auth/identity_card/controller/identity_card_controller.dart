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

  final existingFrontIdUrl = ''.obs;
  final existingBackIdUrl = ''.obs;
  final existingFrontLicenseUrl = ''.obs;
  final existingBackLicenseUrl = ''.obs;

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

  @override
  void onInit() {
    super.onInit();
    _checkAndPrefill();
  }

  void _checkAndPrefill() {
    if (Get.isRegistered<RegistrationController>(tag: 'registration')) {
      final regCtrl = Get.find<RegistrationController>(tag: 'registration');
      if (regCtrl.identityCardNumber.value.isNotEmpty) {
        nidController.text = regCtrl.identityCardNumber.value;
      }
      if (regCtrl.identityCardIssueDate.value.isNotEmpty) {
        identityIssueDate.value =
            _formatIsoToDisplay(regCtrl.identityCardIssueDate.value);
      }
      if (regCtrl.drivingLicenseNumber.value.isNotEmpty) {
        licenseController.text = regCtrl.drivingLicenseNumber.value;
      }
      if (regCtrl.drivingLicenseIssueDate.value.isNotEmpty) {
        drivingLicenseIssueDate.value =
            _formatIsoToDisplay(regCtrl.drivingLicenseIssueDate.value);
      }
      if (regCtrl.licenseClass.value.isNotEmpty) {
        selectedLicenseClass.value =
            regCtrl.unmapLicenseClass(regCtrl.licenseClass.value);
      }
      if (regCtrl.nidFront.value != null) {
        frontIdCard.value = regCtrl.nidFront.value;
      } else if (regCtrl.existingNidFront.value.isNotEmpty) {
        existingFrontIdUrl.value = regCtrl.existingNidFront.value;
      }
      if (regCtrl.nidBack.value != null) {
        backIdCard.value = regCtrl.nidBack.value;
      } else if (regCtrl.existingNidBack.value.isNotEmpty) {
        existingBackIdUrl.value = regCtrl.existingNidBack.value;
      }
      if (regCtrl.dlFront.value != null) {
        frontLicenseCard.value = regCtrl.dlFront.value;
      } else if (regCtrl.existingDlFront.value.isNotEmpty) {
        existingFrontLicenseUrl.value = regCtrl.existingDlFront.value;
      }
      if (regCtrl.dlBack.value != null) {
        backLicenseCard.value = regCtrl.dlBack.value;
      } else if (regCtrl.existingDlBack.value.isNotEmpty) {
        existingBackLicenseUrl.value = regCtrl.existingDlBack.value;
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
    if (frontIdCard.value == null && existingFrontIdUrl.value.isEmpty) {
      EasyLoading.showError('Please upload NRIC front image');
      return;
    }
    if (backIdCard.value == null && existingBackIdUrl.value.isEmpty) {
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
    if (frontLicenseCard.value == null && existingFrontLicenseUrl.value.isEmpty) {
      EasyLoading.showError('Please upload driving license front image');
      return;
    }
    if (backLicenseCard.value == null && existingBackLicenseUrl.value.isEmpty) {
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

    final regCtrl = Get.isRegistered<RegistrationController>(tag: 'registration')
        ? Get.find<RegistrationController>(tag: 'registration')
        : Get.put(RegistrationController(), tag: 'registration');

    regCtrl.identityCardNumber.value = nidController.text.trim();
    if (frontIdCard.value != null) {
      regCtrl.nidFront.value = frontIdCard.value;
    } else if (existingFrontIdUrl.value.isNotEmpty) {
      regCtrl.existingNidFront.value = existingFrontIdUrl.value;
    }

    if (backIdCard.value != null) {
      regCtrl.nidBack.value = backIdCard.value;
    } else if (existingBackIdUrl.value.isNotEmpty) {
      regCtrl.existingNidBack.value = existingBackIdUrl.value;
    }

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

    if (frontLicenseCard.value != null) {
      regCtrl.dlFront.value = frontLicenseCard.value;
    } else if (existingFrontLicenseUrl.value.isNotEmpty) {
      regCtrl.existingDlFront.value = existingFrontLicenseUrl.value;
    }

    if (backLicenseCard.value != null) {
      regCtrl.dlBack.value = backLicenseCard.value;
    } else if (existingBackLicenseUrl.value.isNotEmpty) {
      regCtrl.existingDlBack.value = existingBackLicenseUrl.value;
    }

    Get.to(() => VehicleDetailsScreen());
  }
}
