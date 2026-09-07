import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../core/api_end_point/api_end_point.dart';
import '../../../../core/shared_prefs_service/shared_preference_helper.dart';
import '../../../../routes/app_routes.dart';

class DriverDocumentsController extends GetxController {
  // ================= LOCAL FILE IMAGES =================
  Rx<File?> driverPhoto = Rx<File?>(null);
  Rx<File?> idFront = Rx<File?>(null);
  Rx<File?> idBack = Rx<File?>(null);
  Rx<File?> vehicleLog = Rx<File?>(null);
  Rx<File?> insurancePolicy = Rx<File?>(null);
  Rx<File?> drivingLicenseFront = Rx<File?>(null);
  Rx<File?> drivingLicenseBack = Rx<File?>(null);

  // ================= NETWORK IMAGE URLS =================
  RxList<String> driverPhotoUrls = <String>[].obs; // <-- multiple
  RxString idFrontUrl = ''.obs;
  RxString idBackUrl = ''.obs;
  RxString vehicleLogUrl = ''.obs;
  RxString insurancePolicyUrl = ''.obs;
  RxString drivingLicenseFrontUrl = ''.obs;
  RxString drivingLicenseBackUrl = ''.obs;

  // ================= IDENTITY CARD DATA =================
  RxString nricNumber = ''.obs;
  RxString nricIssueDate = ''.obs;
  RxString drivingLicenseNumber = ''.obs;
  RxString drivingLicenseIssueDate = ''.obs;
  RxString licenseClass = ''.obs;

  final ImagePicker picker = ImagePicker();

  // ================= PICK IMAGE =================
  Future<void> pickImage(Rx<File?> target) async {
    try {
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        target.value = File(file.path);
        debugPrint("Picked image: ${file.path}");
      } else {
        debugPrint("No image selected");
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // ================= FILE UPLOAD =================
  Future<String?> uploadDocumentImage(File? file) async {
    if (file == null) return null;

    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      debugPrint("Uploading file: ${file.path}");

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

      debugPrint("Upload response status: ${response.statusCode}");
      debugPrint("Upload response body: $body");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(body);
        final uploadedUrl = json['data']?[0];
        debugPrint("Uploaded file URL: $uploadedUrl");
        return uploadedUrl;
      }
    } catch (e) {
      debugPrint("Error uploading file: $e");
    }

    return null;
  }

  // ================= GET DOCUMENT DATA =================
  Future<void> getDocumentData() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      debugPrint("Fetching document data with token: $token");

      final response = await http.get(
        Uri.parse(ApiEndPoint.getProfile),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint("Get profile response status: ${response.statusCode}");
      debugPrint("Get profile response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reg = data['data']['raiderProfile']['registrations'][0];

        // ===== DRIVER PHOTOS (multiple) =====
        driverPhotoUrls.value = reg['driver_photos'] is List
            ? List<String>.from(reg['driver_photos'])
            : [reg['driver_photos'] ?? ''];

        // ===== ID FRONT (single) =====
        idFrontUrl.value = reg['nric_front_images'] is List
            ? (reg['nric_front_images'] as List).first
            : (reg['nric_front_images'] ?? '');

        // ===== ID BACK (single) =====
        idBackUrl.value = reg['nric_back_images'] is List
            ? (reg['nric_back_images'] as List).first
            : (reg['nric_back_images'] ?? '');

        // ===== VEHICLE LOG (single) =====
        vehicleLogUrl.value = reg['vehicle_log_images'] is List
            ? (reg['vehicle_log_images'] as List).first
            : (reg['vehicle_log_images'] ?? '');

        // ===== INSURANCE POLICY (single) =====
        insurancePolicyUrl.value = reg['insurance_policy_images'] is List
            ? (reg['insurance_policy_images'] as List).first
            : (reg['insurance_policy_images'] ?? '');

        // ===== DRIVING LICENSE FRONT =====
        drivingLicenseFrontUrl.value = reg['driving_license_front_images'] is List
            ? (reg['driving_license_front_images'] as List).first
            : (reg['driving_license_front_images'] ?? '');

        // ===== DRIVING LICENSE BACK =====
        drivingLicenseBackUrl.value = reg['driving_license_back_images'] is List
            ? (reg['driving_license_back_images'] as List).first
            : (reg['driving_license_back_images'] ?? '');

        // ===== IDENTITY CARD DATA =====
        nricNumber.value = reg['identity_card_number'] ?? '';
        nricIssueDate.value = reg['identity_card_issue_date'] ?? '';
        drivingLicenseNumber.value = reg['driving_license_number'] ?? '';
        drivingLicenseIssueDate.value = reg['driving_license_issue_date'] ?? '';
        licenseClass.value = reg['license_class'] ?? '';

        debugPrint("Document URLs and data loaded successfully");
      } else {
        debugPrint("Failed to fetch document data");
      }
    } catch (e) {
      debugPrint("Error fetching document data: $e");
    }
  }

  // ================= UPDATE DOCUMENT DATA =================
  Future<void> updateDocumentData() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      debugPrint("Updating documents with token: $token");

      final payload = {};

      // Upload driver photo (append to existing driverPhotoUrls)
      final df = await uploadDocumentImage(driverPhoto.value);
      if (df != null) {
        payload['driver_photos'] = [...driverPhotoUrls, df];
      }

      // Upload other documents (single)
      final idf = await uploadDocumentImage(idFront.value);
      final idb = await uploadDocumentImage(idBack.value);
      final log = await uploadDocumentImage(vehicleLog.value);
      final ins = await uploadDocumentImage(insurancePolicy.value);
      final dlf = await uploadDocumentImage(drivingLicenseFront.value);
      final dlb = await uploadDocumentImage(drivingLicenseBack.value);

      if (idf != null) payload['nric_front_images'] = idf;
      if (idb != null) payload['nric_back_images'] = idb;
      if (log != null) payload['vehicle_log_images'] = log;
      if (ins != null) payload['insurance_policy_images'] = ins;
      if (dlf != null) payload['driving_license_front_images'] = dlf;
      if (dlb != null) payload['driving_license_back_images'] = dlb;

      debugPrint("Update payload: ${jsonEncode(payload)}");

      final response = await http.patch(
        Uri.parse(ApiEndPoint.updateRiderProfile),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      debugPrint("Update response status: ${response.statusCode}");
      debugPrint("Update response body: ${response.body}");

      if (response.statusCode == 200) {
        EasyLoading.showSuccess('Documents updated successfully');
        await getDocumentData(); // refresh after update
        await Future.delayed(const Duration(milliseconds: 1500));
        Get.offAllNamed(AppRoutes.getBottomNavbarScreen());
      } else {
        EasyLoading.showError('Documents update failed');
      }
    } catch (e) {
      debugPrint("Error updating documents: $e");
    }
  }

  @override
  void onInit() {
    debugPrint("DriverDocumentsController initialized");
    getDocumentData();
    super.onInit();
  }
}
