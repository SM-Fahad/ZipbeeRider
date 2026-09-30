import 'package:ZipBee_Driver/features/auth/current_address/screen/current_address_screen.dart';
import 'package:ZipBee_Driver/features/auth/registration/controller/registration_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class VehicleCarLogController extends GetxController {
  // Text Controllers
  final chassisNumberController = TextEditingController();
  final policyNumberController = TextEditingController();

  // Separate policy dates
  final policyIssueDate = Rxn<DateTime>();
  final policyExpiryDate = Rxn<DateTime>();

  final vehicleLogFile = Rxn<PlatformFile>();
  final vehiclePolicyFile = Rxn<PlatformFile>();

  final existingVehicleLogUrl = ''.obs;
  final existingVehiclePolicyUrl = ''.obs;

  bool get canContinue =>
      chassisNumberController.text.trim().isNotEmpty &&
      (vehicleLogFile.value != null || existingVehicleLogUrl.value.isNotEmpty);

  @override
  void onClose() {
    chassisNumberController.dispose();
    policyNumberController.dispose();
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
      if (regCtrl.chassisNumber.value.isNotEmpty) {
        chassisNumberController.text = regCtrl.chassisNumber.value;
      }
      if (regCtrl.vehiclePolicyNumber.value.isNotEmpty) {
        policyNumberController.text = regCtrl.vehiclePolicyNumber.value;
      }
      if (regCtrl.vehiclePolicyIssueDate.value.isNotEmpty) {
        try {
          policyIssueDate.value =
              DateTime.parse(regCtrl.vehiclePolicyIssueDate.value);
        } catch (_) {}
      }
      if (regCtrl.vehiclePolicyExpireDate.value.isNotEmpty) {
        try {
          policyExpiryDate.value =
              DateTime.parse(regCtrl.vehiclePolicyExpireDate.value);
        } catch (_) {}
      }
      if (regCtrl.vehicleLogFile != null) {
        vehicleLogFile.value = regCtrl.vehicleLogFile;
      } else if (regCtrl.existingVehicleLog.value.isNotEmpty) {
        existingVehicleLogUrl.value = regCtrl.existingVehicleLog.value;
      }
      if (regCtrl.vehiclePolicyFile != null) {
        vehiclePolicyFile.value = regCtrl.vehiclePolicyFile;
      } else if (regCtrl.existingVehiclePolicy.value.isNotEmpty) {
        existingVehiclePolicyUrl.value = regCtrl.existingVehiclePolicy.value;
      }
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return "";
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  // ---------------- DATE PICKER ----------------
  Future<void> pickDate({required bool isIssue, bool isPolicy = false}) async {
    final lastAllowedIssueDate = DateTime.now().subtract(
      const Duration(days: 1),
    );
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: isIssue ? lastAllowedIssueDate : DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: isIssue ? lastAllowedIssueDate : DateTime(2100),
    );

    if (picked != null) {
      if (isPolicy) {
        if (isIssue) {
          policyIssueDate.value = picked;
        } else {
          policyExpiryDate.value = picked;
        }
      }
    }
  }

  void submitVehicleDetails() {
    if (chassisNumberController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter chassis number');
      return;
    }
    if (vehicleLogFile.value == null && existingVehicleLogUrl.value.isEmpty) {
      EasyLoading.showError('Please upload vehicle log card');
      return;
    }
    if (policyNumberController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter insurance policy number');
      return;
    }
    if (policyIssueDate.value == null) {
      EasyLoading.showError('Please select insurance policy issue date');
      return;
    }
    if (policyExpiryDate.value == null) {
      EasyLoading.showError('Please select insurance policy expiry date');
      return;
    }
    if (vehiclePolicyFile.value == null &&
        existingVehiclePolicyUrl.value.isEmpty) {
      EasyLoading.showError('Please upload insurance policy document');
      return;
    }

    if (!policyIssueDate.value!.isBefore(DateTime.now())) {
      EasyLoading.showError('Issue date must be earlier than today');
      return;
    }

    final regCtrl = Get.isRegistered<RegistrationController>(tag: 'registration')
        ? Get.find<RegistrationController>(tag: 'registration')
        : Get.put(RegistrationController(), tag: 'registration');

    regCtrl.chassisNumber.value = chassisNumberController.text.trim();
    if (vehicleLogFile.value != null) {
      regCtrl.vehicleLogFile = vehicleLogFile.value;
    } else if (existingVehicleLogUrl.value.isNotEmpty) {
      regCtrl.existingVehicleLog.value = existingVehicleLogUrl.value;
    }

    // policy
    regCtrl.vehiclePolicyNumber.value = policyNumberController.text.trim();
    if (policyIssueDate.value != null) {
      regCtrl.vehiclePolicyIssueDate.value =
          policyIssueDate.value!.toIso8601String() + 'Z';
    }
    if (policyExpiryDate.value != null) {
      regCtrl.vehiclePolicyExpireDate.value =
          policyExpiryDate.value!.toIso8601String() + 'Z';
    }

    if (vehiclePolicyFile.value != null) {
      regCtrl.vehiclePolicyFile = vehiclePolicyFile.value;
    } else if (existingVehiclePolicyUrl.value.isNotEmpty) {
      regCtrl.existingVehiclePolicy.value = existingVehiclePolicyUrl.value;
    }

    Get.to(() => CurrentAddressScreen());
  }

  Future<void> pickVehicleLogFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'jpeg'],
      withData: true,
    );

    if (result != null) {
      final file = result.files.first;

      if (file.size <= 25 * 1024 * 1024) {
        vehicleLogFile.value = file;
      } else {
        vehicleLogFile.value = null;
        EasyLoading.showError("File size must be under 25MB");
      }
    }
  }

  Future<void> pickPolicyFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'jpeg'],
      withData: true,
    );

    if (result != null) {
      final file = result.files.first;

      if (file.size <= 25 * 1024 * 1024) {
        vehiclePolicyFile.value = file;
      } else {
        vehiclePolicyFile.value = null;
        EasyLoading.showError("File size must be under 25MB");
      }
    }
  }
}
