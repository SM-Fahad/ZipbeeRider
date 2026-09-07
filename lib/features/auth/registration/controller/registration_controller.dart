import 'dart:io';
import 'dart:convert';

import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class RegistrationController extends GetxController {
  // ================= RIDER BASIC =================
  var raiderName = ''.obs;
  var contactNumber = ''.obs;
  var email = ''.obs;
  var dob = ''.obs;
  var gender = ''.obs;

  var driverPhotos = <File>[].obs;

  var emergencyContactName = ''.obs;
  var emergencyContactNumber = ''.obs;

  // ================= IDENTITY =================
  var identityCardNumber = ''.obs;
  var identityCardIssueDate = ''.obs;
  var nidFront = Rx<File?>(null);
  var nidBack = Rx<File?>(null);

  var drivingLicenseNumber = ''.obs;
  var drivingLicenseIssueDate = ''.obs;
  var licenseClass = ''.obs;
  var dlFront = Rx<File?>(null);
  var dlBack = Rx<File?>(null);

  // ================= VEHICLE =================
  var vehiclePlateNumber = ''.obs;
  var vehicleType = ''.obs;
  var vehicleBrand = ''.obs;
  var vehicleModel = ''.obs;
  var registrationDate = ''.obs;

  var vehicleFront = Rx<File?>(null);
  var vehicleBack = Rx<File?>(null);
  var vehicleDriverSide = Rx<File?>(null);
  var vehiclePassengerSide = Rx<File?>(null);

  // ================= LOG & POLICY =================
  var chassisNumber = ''.obs;
  PlatformFile? vehicleLogFile;

  var vehiclePolicyNumber = ''.obs;
  var vehiclePolicyIssueDate = ''.obs;
  var vehiclePolicyExpireDate = ''.obs;
  PlatformFile? vehiclePolicyFile;

  // ================= ADDRESS =================
  var currentAddress = ''.obs;
  var currentApartment = ''.obs;
  var currentStateProvince = ''.obs;
  var currentCountry = 'Singapore'.obs;
  var currentZipPostCode = ''.obs;

  var permanentAddress = ''.obs;
  var permanentApartment = ''.obs;
  var permanentStateProvince = ''.obs;
  var permanentCountry = 'Singapore'.obs;
  var permanentZipPostCode = ''.obs;

  // ================= BANK =================
  var bankName = ''.obs;
  var accountNumber = ''.obs;

  var isLoading = false.obs;

  // ================= HELPERS =================
  String formatDate(DateTime date) => date.toIso8601String() + 'Z';

  String mapLicenseClass(String value) {
    switch (value.trim()) {
      case 'Class 2B':
        return 'CLASS_2B';
      case 'Class 2A':
        return 'CLASS_2A';
      case 'Class 2':
        return 'CLASS_2';
      case 'Class 3':
        return 'CLASS_3';
      case 'Class 3A':
        return 'CLASS_3A';
      case 'Class 4':
        return 'CLASS_4';
      case 'Class 5':
        return 'CLASS_5';
      default:
        return value.trim();
    }
  }

  void putIfNotEmpty(Map<String, dynamic> payload, String key, dynamic value) {
    if (value == null) return;
    if (value is String) {
      if (value.trim().isEmpty) return;
      payload[key] = value.trim();
      return;
    }
    if (value is List) {
      if (value.isEmpty) return;
      payload[key] = value;
      return;
    }
    payload[key] = value;
  }

  // ================= FILE UPLOAD =================
  Future<List<String>> uploadFiles(List<File> files) async {
    final List<String> urls = [];

    for (final file in files) {
      if (!file.existsSync()) continue;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndPoint.fileUpload),
      );

      request.files.add(await http.MultipartFile.fromPath('images', file.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      debugPrint('📤 Upload response: $body');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(body);
        if (json['success'] == true && json['data'] != null) {
          urls.add(json['data'][0]);
        }
      }
    }
    return urls;
  }

  Future<String?> uploadPlatformFile(PlatformFile? file) async {
    if (file == null) return null;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiEndPoint.fileUpload),
    );

    if (file.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'images',
          file.bytes!,
          filename: file.name,
        ),
      );
    } else if (file.path != null) {
      request.files.add(
        await http.MultipartFile.fromPath('images', file.path!),
      );
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    debugPrint('📤 Upload response: $body');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(body);
      if (json['success'] == true && json['data'] != null) {
        return json['data'][0];
      }
    }
    return null;
  }

  // ================= SUBMIT REGISTRATION =================
  Future<bool> submitRegistration() async {
    final prefEmail = await SharedPreferencesHelper.getEmail();
    final resolvedEmail = (prefEmail != null && prefEmail.trim().isNotEmpty)
        ? prefEmail.trim()
        : email.value.trim();
    final token = await SharedPreferencesHelper.getAccessToken();

    debugPrint('🔑 Access token: $token');

    if (token == null) {
      EasyLoading.showError('Access token not found. Please login again.');
      return false;
    }

    debugPrint('✅ USING TOKEN => $token');

    try {
      EasyLoading.showInfo('Uploading files...');

      isLoading.value = true;

      final driverPhotoUrls = await uploadFiles(driverPhotos);
      final nidFrontUrls = nidFront.value != null
          ? await uploadFiles([nidFront.value!])
          : [];
      final nidBackUrls = nidBack.value != null
          ? await uploadFiles([nidBack.value!])
          : [];
      final dlFrontUrls = dlFront.value != null
          ? await uploadFiles([dlFront.value!])
          : [];
      final dlBackUrls = dlBack.value != null
          ? await uploadFiles([dlBack.value!])
          : [];

      final vehicleFrontUrls = vehicleFront.value != null
          ? await uploadFiles([vehicleFront.value!])
          : [];
      final vehicleBackUrls = vehicleBack.value != null
          ? await uploadFiles([vehicleBack.value!])
          : [];

      final vehicleDriverUrls = vehicleDriverSide.value != null
          ? await uploadFiles([vehicleDriverSide.value!])
          : [];
      final vehiclePassengerUrls = vehiclePassengerSide.value != null
          ? await uploadFiles([vehiclePassengerSide.value!])
          : [];

      final vehicleLogUrl = await uploadPlatformFile(vehicleLogFile);
      final insurancePolicyUrl = await uploadPlatformFile(vehiclePolicyFile);
      final Map<String, dynamic> payload = {};

      putIfNotEmpty(payload, 'raider_name', raiderName.value);
      putIfNotEmpty(payload, 'contact_number', contactNumber.value);
      putIfNotEmpty(payload, 'email_address', resolvedEmail);
      putIfNotEmpty(payload, 'dob', dob.value);
      putIfNotEmpty(payload, 'gender', gender.value.toUpperCase());
      putIfNotEmpty(
        payload,
        'emergency_contact_name',
        emergencyContactName.value,
      );
      putIfNotEmpty(
        payload,
        'emergency_contact_number',
        emergencyContactNumber.value,
      );

      putIfNotEmpty(payload, 'identity_card_number', identityCardNumber.value);
      putIfNotEmpty(
        payload,
        'identity_card_issue_date',
        identityCardIssueDate.value,
      );
      putIfNotEmpty(
        payload,
        'driving_license_number',
        drivingLicenseNumber.value,
      );
      putIfNotEmpty(
        payload,
        'driving_license_issue_date',
        drivingLicenseIssueDate.value,
      );
      putIfNotEmpty(
        payload,
        'driving_license_expire_date',
        identityCardIssueDate.value,
      );
      if (licenseClass.value.trim().isNotEmpty) {
        payload['license_class'] = mapLicenseClass(licenseClass.value);
      }

      putIfNotEmpty(payload, 'vehicle_plate_number', vehiclePlateNumber.value);
      if (vehicleType.value.trim().isNotEmpty) {
        payload['vehicle_type_id'] = int.tryParse(vehicleType.value);
      }
      putIfNotEmpty(payload, 'vehicle_brand', vehicleBrand.value);
      putIfNotEmpty(payload, 'vehicle_model', vehicleModel.value);
      putIfNotEmpty(payload, 'registration_date', registrationDate.value);

      putIfNotEmpty(payload, 'chassis_number', chassisNumber.value);
      putIfNotEmpty(
        payload,
        'insurance_policy_number',
        vehiclePolicyNumber.value,
      );
      putIfNotEmpty(
        payload,
        'insurance_issue_date',
        vehiclePolicyIssueDate.value,
      );
      putIfNotEmpty(
        payload,
        'insurance_expiry_date',
        vehiclePolicyExpireDate.value,
      );

      putIfNotEmpty(payload, 'current_postal_code', currentZipPostCode.value);
      putIfNotEmpty(payload, 'current_address', currentAddress.value);
      putIfNotEmpty(payload, 'current_unit', currentApartment.value);
      putIfNotEmpty(payload, 'current_country', currentCountry.value);

      putIfNotEmpty(
        payload,
        'permanent_postal_code',
        permanentZipPostCode.value,
      );
      putIfNotEmpty(payload, 'permanent_address', permanentAddress.value);
      putIfNotEmpty(payload, 'permanent_unit', permanentApartment.value);
      putIfNotEmpty(payload, 'permanent_country', permanentCountry.value);

      putIfNotEmpty(payload, 'bank_name', bankName.value);
      putIfNotEmpty(payload, 'account_number', accountNumber.value);

      putIfNotEmpty(payload, 'driver_photos', driverPhotoUrls);
      if (nidFrontUrls.isNotEmpty) {
        payload['nric_front_images'] = nidFrontUrls.first;
      }
      if (nidBackUrls.isNotEmpty) {
        payload['nric_back_images'] = nidBackUrls.first;
      }
      if (dlFrontUrls.isNotEmpty) {
        payload['driving_license_front_images'] = dlFrontUrls.first;
      }
      if (dlBackUrls.isNotEmpty) {
        payload['driving_license_back_images'] = dlBackUrls.first;
      }
      if (vehicleFrontUrls.isNotEmpty) {
        payload['vehicle_front_images'] = vehicleFrontUrls.first;
      }
      if (vehicleBackUrls.isNotEmpty) {
        payload['vehicle_back_images'] = vehicleBackUrls.first;
      }
      if (vehicleDriverUrls.isNotEmpty) {
        payload['vehicle_driver_side_images'] = vehicleDriverUrls.first;
      }
      if (vehiclePassengerUrls.isNotEmpty) {
        payload['vehicle_passenger_side_images'] = vehiclePassengerUrls.first;
      }
      if (vehicleLogUrl != null && vehicleLogUrl.trim().isNotEmpty) {
        payload['vehicle_log_images'] = vehicleLogUrl;
      }
      if (insurancePolicyUrl != null && insurancePolicyUrl.trim().isNotEmpty) {
        payload['insurance_policy_images'] = insurancePolicyUrl;
      }

      void printFullLog(String text) {
        final pattern = RegExp('.{1,800}'); // 800 characters per line
        pattern.allMatches(text).forEach((match) => print(match.group(0)));
      }

      printFullLog('📥Regis PAYLOAD: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse(ApiEndPoint.riderRegistration),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      printFullLog('📥Regis RESPONSE ${response.statusCode}: ${response.body}');

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        EasyLoading.showSuccess('Rider registration successful');
        isLoading.value = false;
        return true;
      } else {
        // Handle error message (can be String or List of Strings)
        String errorMessage = 'Registration failed';
        if (data['message'] != null) {
          if (data['message'] is List) {
            errorMessage = (data['message'] as List).join('\n');
          } else {
            errorMessage = data['message'].toString();
          }
        }
        EasyLoading.showError(errorMessage);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Registration exception: $e');
      //Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
