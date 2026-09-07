import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/api_end_point/api_end_point.dart';
import '../../../core/shared_prefs_service/shared_preference_helper.dart';
import '../../account/controller/account_controller.dart';

class ProfileController extends GetxController {
  final raiderName = TextEditingController();
  final contactNumber = TextEditingController();
  final emailAddress = TextEditingController();
  final dob = TextEditingController();
  final gender = ''.obs;
  final emergencyContactName = TextEditingController();
  final emergencyContactNumber = TextEditingController();

  // bank info
  final bankName = TextEditingController();
  final accountNumber = TextEditingController();
  final bankNameRx = ''.obs;
  final accountNumberRx = ''.obs;

  final isLoading = false.obs;
  final profilePhoto = Rx<File?>(null);
  final picker = ImagePicker();

  String oldRaiderName = '';
  String oldContactNumber = '';
  String oldEmailAddress = '';
  String oldDob = '';
  String oldGender = '';
  String oldEmergencyContactName = '';
  String oldEmergencyContactNumber = '';

  // ✅ Inject AccountController
  final AccountController accountController = Get.find<AccountController>();

  @override
  void onInit() {
    super.onInit();
    getProfileData();
  }

  // ---------------- GET PROFILE ----------------
  Future<void> getProfileData() async {
    isLoading.value = true;

    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final response = await http.get(
        Uri.parse(ApiEndPoint.getProfile),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint(
        "GET PROFILE RESPONSE: ${response.statusCode} - ${response.body}",
        wrapWidth: 10240,
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        final data = res['data'];

        final raiderProfile = data['raiderProfile'];
        final registrations = raiderProfile?['registrations'] as List?;

        if (registrations != null && registrations.isNotEmpty) {
          final rider = registrations[0];

          oldRaiderName = rider['raider_name'] ?? '';
          oldContactNumber = rider['contact_number'] ?? '';
          oldEmailAddress = rider['email_address'] ?? '';
          oldGender = rider['gender'] ?? '';
          oldEmergencyContactName = rider['emergency_contact_name'] ?? '';
          oldEmergencyContactNumber = rider['emergency_contact_number'] ?? '';

          String rawDob = rider['dob'] ?? '';
          if (rawDob.contains('T')) {
            oldDob = rawDob.split('T')[0]; // result demo: "2004-05-12"
          } else {
            oldDob = rawDob;
          }

          raiderName.text = oldRaiderName;
          contactNumber.text = oldContactNumber;
          emailAddress.text = oldEmailAddress;
          dob.text = oldDob;
          gender.value = oldGender;
          emergencyContactName.text = oldEmergencyContactName;
          emergencyContactNumber.text = oldEmergencyContactNumber;

          bankName.text = rider['bank_name'] ?? '';
          accountNumber.text = rider['account_number'] ?? '';
          bankNameRx.value = rider['bank_name'] ?? '';
          accountNumberRx.value = rider['account_number'] ?? '';
        }
      }
    } catch (e) {
      debugPrint("GET PROFILE ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- PICK PROFILE PHOTO ----------------
  Future<void> pickProfilePhoto() async {
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

      profilePhoto.value = file;
    }
  }

  // ---------------- UPLOAD FILE ----------------
  Future<String?> uploadProfilePhoto(File file) async {
    try {
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
          return json['data'][0];
        }
      }
    } catch (e) {
      debugPrint('Upload error: $e');
    }
    return null;
  }

  Future<void> saveProfile() async {
    isLoading.value = true;

    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final Map<String, dynamic> updatedData = {};

      if (raiderName.text.trim() != oldRaiderName) {
        updatedData['raider_name'] = raiderName.text.trim();
      }

      if (contactNumber.text.trim() != oldContactNumber) {
        updatedData['contact_number'] = contactNumber.text.trim();
      }

      if (emailAddress.text.trim() != oldEmailAddress) {
        updatedData['email_address'] = emailAddress.text.trim();
      }

      if (dob.text.trim() != oldDob) {
        updatedData['dob'] = dob.text.trim();
      }

      if (gender.value != oldGender && gender.value.isNotEmpty) {
        updatedData['gender'] = gender.value;
      }

      if (emergencyContactName.text.trim() != oldEmergencyContactName) {
        updatedData['emergency_contact_name'] = emergencyContactName.text
            .trim();
      }

      if (emergencyContactNumber.text.trim() != oldEmergencyContactNumber) {
        updatedData['emergency_contact_number'] = emergencyContactNumber.text
            .trim();
      }

      // Upload profile photo if selected
      if (profilePhoto.value != null) {
        final photoUrl = await uploadProfilePhoto(profilePhoto.value!);
        if (photoUrl != null) {
          updatedData['driver_photos'] = [photoUrl];
        }
      }

      if (updatedData.isEmpty) {
        EasyLoading.showInfo("No changes detected");
        debugPrint("NO CHANGES DETECTED");
        return;
      }

      debugPrint("Updating with: $updatedData");

      final response = await http.patch(
        Uri.parse(ApiEndPoint.updateRiderProfile),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(updatedData),
      );

      debugPrint(
        "UPDATE PROFILE RESPONSE: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 200) {
        EasyLoading.showSuccess("Profile updated successfully");
        await getProfileData();
        profilePhoto.value = null;

        // ✅ Update AccountController reactively
        accountController.riderName.value = raiderName.text.trim();

        debugPrint("PROFILE UPDATED AND ACCOUNT CONTROLLER SYNCED");
      } else {
        EasyLoading.showError("Failed to update profile");
        debugPrint("UPDATE FAILED: ${response.body}");
      }
    } catch (e) {
      EasyLoading.showError("Error updating profile: $e");
      debugPrint("UPDATE PROFILE ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- SOFT DELETE ----------------
  Future<void> deleteProfile() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      final response = await http.patch(
        Uri.parse(ApiEndPoint.softDelete),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        await SharedPreferencesHelper.clearAllData();
        Get.offAllNamed('/login');
      }
    } catch (e) {
      debugPrint("DELETE PROFILE ERROR: $e");
    }
  }

  @override
  void onClose() {
    raiderName.dispose();
    contactNumber.dispose();
    emailAddress.dispose();
    dob.dispose();
    emergencyContactName.dispose();
    emergencyContactNumber.dispose();
    bankName.dispose();
    accountNumber.dispose();
    super.onClose();
  }
}
