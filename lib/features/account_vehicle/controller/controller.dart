import 'dart:convert';
import 'dart:io';

import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/auth/vehicle_details/model/vehicle_type_option_model.dart';
import 'package:ZipBee_Driver/features/auth/vehicle_details/service/vehicle_type_service.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class VehicleController extends GetxController {
  // ================= TEXT CONTROLLERS =================
  final vehiclePlateCtrl = TextEditingController();
  final vehicleTypeCtrl = TextEditingController();
  final vehicleBrandCtrl = TextEditingController();
  final vehicleModelCtrl = TextEditingController();
  final chassisNumberCtrl = TextEditingController();
  final vehiclePolicyCtrl = TextEditingController();

  // ================= DATES =================
  Rx<DateTime?> registrationDate = Rx<DateTime?>(null);
  Rx<DateTime?> policyIssueDate = Rx<DateTime?>(null);
  Rx<DateTime?> policyExpireDate = Rx<DateTime?>(null);

  // ================= LOCAL FILE IMAGES =================
  Rx<File?> vehicleFront = Rx<File?>(null);
  Rx<File?> vehicleBack = Rx<File?>(null);
  Rx<File?> vehicleDriverSide = Rx<File?>(null);
  Rx<File?> vehiclePassengerSide = Rx<File?>(null);
  Rx<File?> vehicleLogImage = Rx<File?>(null);
  Rx<File?> policyImage = Rx<File?>(null);

  // ================= NETWORK IMAGE URLS =================
  RxString vehicleFrontUrl = ''.obs;
  RxString vehicleBackUrl = ''.obs;
  RxString vehicleDriverSideUrl = ''.obs;
  RxString vehiclePassengerSideUrl = ''.obs;
  RxString vehicleLogImageUrl = ''.obs;
  RxString policyImageUrl = ''.obs;

  // ================= LOADING STATE =================
  final isLoading = true.obs;

  // ================= VEHICLE TYPES =================
  final vehicleTypes = <VehicleTypeOptionModel>[].obs;
  final isVehicleTypesLoading = false.obs;
  final vehicleTypeId = 0.obs;
  final vehicleTypeName = ''.obs;

  final ImagePicker _picker = ImagePicker();
  final VehicleTypeService _vehicleTypeService = VehicleTypeService();

  // ================= PICK IMAGE =================
  Future<void> pickImage(Rx<File?> target) async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      target.value = File(file.path);
    }
  }

  // ================= PICK DATE =================
  Future<void> pickDate(Rx<DateTime?> target) async {
    final date = await showDatePicker(
      context: Get.context!,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
      initialDate: target.value ?? DateTime.now(),
    );
    if (date != null) {
      target.value = date;
    }
  }

  // ================= FILE UPLOAD =================
  Future<String?> uploadImage(File? file) async {
    if (file == null) return null;

    final token = await SharedPreferencesHelper.getAccessToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiEndPoint.fileUpload),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.files.add(await http.MultipartFile.fromPath('images', file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(body);
      return json['data']?[0];
    }
    return null;
  }

  // ================= GET VEHICLE DATA =================
  Future<void> getVehicleData() async {
    try {
      isLoading.value = true;
      final token = await SharedPreferencesHelper.getAccessToken();

      final response = await http.get(
        Uri.parse(ApiEndPoint.getProfile),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reg = data['data']['raiderProfile']['registrations'][0];

        vehiclePlateCtrl.text = reg['vehicle_plate_number'] ?? '';
        final typeId =
            int.tryParse(reg['vehicle_type_id']?.toString() ?? '0') ?? 0;
        vehicleTypeCtrl.text = typeId.toString();
        vehicleTypeId.value = typeId;
        vehicleTypeName.value = getVehicleTypeName(typeId);
        vehicleBrandCtrl.text = reg['vehicle_brand'] ?? '';
        vehicleModelCtrl.text = reg['vehicle_model'] ?? '';
        chassisNumberCtrl.text = reg['chassis_number'] ?? '';
        vehiclePolicyCtrl.text = reg['insurance_policy_number'] ?? '';

        registrationDate.value = DateTime.tryParse(
          reg['registration_date'] ?? '',
        );
        policyIssueDate.value = DateTime.tryParse(
          reg['insurance_issue_date'] ?? '',
        );
        policyExpireDate.value = DateTime.tryParse(
          reg['insurance_expiry_date'] ?? '',
        );

        // ===== IMAGE URLS FROM API =====
        vehicleFrontUrl.value = reg['vehicle_front_images'] ?? '';
        vehicleBackUrl.value = reg['vehicle_back_images'] ?? '';
        vehicleDriverSideUrl.value = reg['vehicle_driver_side_images'] ?? '';
        vehiclePassengerSideUrl.value =
            reg['vehicle_passenger_side_images'] ?? '';
        vehicleLogImageUrl.value = reg['vehicle_log_images'] ?? '';
        policyImageUrl.value = reg['insurance_policy_images'] ?? '';
      }
    } catch (e) {
      debugPrint('Error loading vehicle data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ================= UPDATE VEHICLE =================
  Future<void> updateVehicleData() async {
    final token = await SharedPreferencesHelper.getAccessToken();

    final payload = {
      'vehicle_plate_number': vehiclePlateCtrl.text,
      'vehicle_type_id': int.tryParse(vehicleTypeCtrl.text),
      'vehicle_brand': vehicleBrandCtrl.text,
      'vehicle_model': vehicleModelCtrl.text,
      'registration_date': registrationDate.value?.toIso8601String(),
      'chassis_number': chassisNumberCtrl.text,
      'insurance_policy_number': vehiclePolicyCtrl.text,
      'insurance_issue_date': policyIssueDate.value?.toIso8601String(),
      'insurance_expiry_date': policyExpireDate.value?.toIso8601String(),
    };

    final vf = await uploadImage(vehicleFront.value);
    final vb = await uploadImage(vehicleBack.value);
    final vds = await uploadImage(vehicleDriverSide.value);
    final vps = await uploadImage(vehiclePassengerSide.value);
    final logImg = await uploadImage(vehicleLogImage.value);
    final policy = await uploadImage(policyImage.value);

    if (vf != null) payload['vehicle_front_images'] = vf;
    if (vb != null) payload['vehicle_back_images'] = vb;
    if (vds != null) payload['vehicle_driver_side_images'] = vds;
    if (vps != null) payload['vehicle_passenger_side_images'] = vps;
    if (logImg != null) payload['vehicle_log_images'] = logImg;
    if (policy != null) payload['insurance_policy_images'] = policy;

    final response = await http.patch(
      Uri.parse(ApiEndPoint.updateRiderProfile),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      EasyLoading.showSuccess('Vehicle updated successfully');
      await Future.delayed(const Duration(seconds: 1));
      await EasyLoading.dismiss();
      Get.offNamed(AppRoutes.viewVehicleScreen);
    } else {
      EasyLoading.showError('Failed to update vehicle');
      EasyLoading.dismiss();
    }
  }

  @override
  void onInit() {
    fetchVehicleTypes();
    getVehicleData();
    super.onInit();
  }

  // ================= FETCH VEHICLE TYPES =================
  Future<void> fetchVehicleTypes() async {
    try {
      isVehicleTypesLoading.value = true;
      final fetchedVehicleTypes = await _vehicleTypeService.fetchVehicleTypes();
      vehicleTypes.assignAll(fetchedVehicleTypes);
    } catch (e) {
      debugPrint('Error loading vehicle types: $e');
    } finally {
      isVehicleTypesLoading.value = false;
    }
  }

  // ================= GET VEHICLE TYPE NAME =================
  String getVehicleTypeName(int vehicleTypeId) {
    try {
      final vehicleType = vehicleTypes.firstWhere(
        (type) => type.id == vehicleTypeId,
        orElse: () =>
            VehicleTypeOptionModel(id: 0, vehicleType: '', vehicleName: ''),
      );
      return vehicleType.vehicleName;
    } catch (e) {
      return '';
    }
  }

  @override
  void onClose() {
    vehiclePlateCtrl.dispose();
    vehicleTypeCtrl.dispose();
    vehicleBrandCtrl.dispose();
    vehicleModelCtrl.dispose();
    chassisNumberCtrl.dispose();
    vehiclePolicyCtrl.dispose();
    super.onClose();
  }
}
