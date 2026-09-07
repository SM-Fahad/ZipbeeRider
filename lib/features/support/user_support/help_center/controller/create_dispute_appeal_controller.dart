import 'dart:convert';
import 'dart:io';

import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CreateDisputeAppealController extends GetxController {
  CreateDisputeAppealController({
    required this.orderDisputeId,
    required this.orderId,
  });

  final int orderDisputeId;
  final int orderId;
  final TextEditingController reasonController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final RxnString fileUrl = RxnString();
  final Rxn<File> pickedImage = Rxn<File>();
  final RxBool isUploadingImage = false.obs;
  final RxBool isSubmitting = false.obs;

  Future<void> pickAndUploadImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (file == null) return;

      isUploadingImage.value = true;
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('Access token not found');
        return;
      }

      final localFile = File(file.path);
      final uploadedUrl = await _uploadImage(localFile, token);
      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        pickedImage.value = localFile;
        fileUrl.value = uploadedUrl;
        EasyLoading.showSuccess('Proof uploaded successfully');
      }
    } catch (e) {
      debugPrint('Appeal image pick/upload error: $e');
      EasyLoading.showError('Failed to upload proof');
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<String?> _uploadImage(File file, String token) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndPoint.upload),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': '*/*',
      });
      request.files.add(await http.MultipartFile.fromPath('images', file.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json =
            _tryDecodeMap(body) ?? <String, dynamic>{};
        final List<dynamic> data = json['data'] as List<dynamic>? ?? [];
        if (data.isNotEmpty) {
          return data.first.toString();
        }
      }

      final Map<String, dynamic>? json = _tryDecodeMap(body);
      EasyLoading.showError(
        json?['message']?.toString() ?? 'Failed to upload image',
      );
    } catch (e) {
      debugPrint('Appeal upload image error: $e');
      EasyLoading.showError('Failed to upload image');
    }
    return null;
  }

  void removeProof() {
    pickedImage.value = null;
    fileUrl.value = null;
  }

  Future<void> submitAppeal() async {
    final reason = reasonController.text.trim();
    final uploadedFileUrl = fileUrl.value?.trim();

    if (reason.isEmpty) {
      EasyLoading.showError('Reason is required');
      return;
    }

    if (isUploadingImage.value) {
      EasyLoading.showInfo('Please wait for proof upload to finish');
      return;
    }

    if (uploadedFileUrl == null || uploadedFileUrl.isEmpty) {
      EasyLoading.showError('Proof image is required');
      return;
    }

    try {
      isSubmitting.value = true;
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('Access token not found');
        return;
      }

      final response = await http.post(
        Uri.parse(ApiEndPoint.disputeAppeals),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'orderDisputeId': orderDisputeId,
          'orderId': orderId,
          'reason': reason,
          'fileUrl': uploadedFileUrl,
        }),
      );

      final Map<String, dynamic> body =
          _tryDecodeMap(response.body) ?? <String, dynamic>{};

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body['success'] == true) {
        EasyLoading.showSuccess(
          body['message']?.toString() ?? 'Appeal filed successfully',
        );
        Get.back(result: true);
        return;
      }

      EasyLoading.showError(
        body['message']?.toString() ?? 'Failed to file appeal',
      );
    } catch (e) {
      debugPrint('Create appeal error: $e');
      EasyLoading.showError('Something went wrong');
    } finally {
      isSubmitting.value = false;
    }
  }

  Map<String, dynamic>? _tryDecodeMap(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }
}
