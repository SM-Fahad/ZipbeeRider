import 'dart:io';
import 'package:ZipBee_Driver/features/auth/registration/controller/registration_controller.dart';
import 'package:ZipBee_Driver/features/auth/vehicle_details/model/vehicle_type_option_model.dart';
import 'package:ZipBee_Driver/features/auth/vehicle_details/service/vehicle_type_service.dart';
import 'package:ZipBee_Driver/features/auth/vehicle_car_log/screen/vehicle_car_log_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class VehicleDetailsController extends GetxController {
  final plateNumberController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final registrationDateController = TextEditingController();

  final selectedType = ''.obs;
  final vehicleTypes = <VehicleTypeOptionModel>[].obs;
  final isVehicleTypesLoading = false.obs;

  final frontImage = Rx<File?>(null);
  final backImage = Rx<File?>(null);
  final driverImage = Rx<File?>(null);
  final passengerImage = Rx<File?>(null);

  final picker = ImagePicker();
  final VehicleTypeService _vehicleTypeService = VehicleTypeService();

  @override
  void onInit() {
    super.onInit();
    fetchVehicleTypes();
  }

  Future<void> fetchVehicleTypes() async {
    try {
      isVehicleTypesLoading.value = true;
      final fetchedVehicleTypes = await _vehicleTypeService.fetchVehicleTypes();
      vehicleTypes.assignAll(fetchedVehicleTypes);

      if (vehicleTypes.isNotEmpty && selectedType.value.isEmpty) {
        selectedType.value = vehicleTypes.first.id.toString();
      }
    } catch (e) {
      EasyLoading.showError('Failed to load vehicle types');
    } finally {
      isVehicleTypesLoading.value = false;
    }
  }

  Future<void> pickImage(Rx<File?> imageRx) async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked != null) {
      final file = File(picked.path);
      final fileSizeInBytes = await file.length();

      if (fileSizeInBytes > 5 * 1024 * 1024) {
        EasyLoading.showError("Image size must be under 5MB");
        return;
      }

      imageRx.value = file;
    }
  }

  void removeImage(Rx<File?> imageRx) {
    imageRx.value = null;
  }

  void selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      registrationDateController.text =
          "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  void continueNext() {
    if (plateNumberController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter vehicle plate number');
      return;
    }
    if (selectedType.value.trim().isEmpty) {
      EasyLoading.showError('Please select vehicle type');
      return;
    }
    if (brandController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter vehicle brand');
      return;
    }
    if (modelController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter vehicle model');
      return;
    }
    if (registrationDateController.text.trim().isEmpty) {
      EasyLoading.showError('Please select registration date');
      return;
    }
    if (frontImage.value == null) {
      EasyLoading.showError('Please upload vehicle front image');
      return;
    }
    if (backImage.value == null) {
      EasyLoading.showError('Please upload vehicle back image');
      return;
    }
    if (driverImage.value == null) {
      EasyLoading.showError('Please upload driver side vehicle image');
      return;
    }
    if (passengerImage.value == null) {
      EasyLoading.showError('Please upload passenger side vehicle image');
      return;
    }

    final regCtrl = Get.put(RegistrationController(), tag: 'registration');

    regCtrl.vehiclePlateNumber.value = plateNumberController.text.trim();
    regCtrl.vehicleType.value = selectedType.value;
    regCtrl.vehicleBrand.value = brandController.text.trim();
    regCtrl.vehicleModel.value = modelController.text.trim();

    // convert dd/MM/yyyy to ISO-8601
    try {
      final parts = registrationDateController.text.split('/');
      if (parts.length == 3) {
        final d = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        regCtrl.registrationDate.value = d.toIso8601String() + 'Z';
      }
    } catch (e) {}

    regCtrl.vehicleFront.value = frontImage.value;
    regCtrl.vehicleBack.value = backImage.value;
    regCtrl.vehicleDriverSide.value = driverImage.value;
    regCtrl.vehiclePassengerSide.value = passengerImage.value;

    Get.to(VehicleCarLogScreen());
  }
}
