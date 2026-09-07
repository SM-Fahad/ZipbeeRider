import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class FileUploadService {
  final baseUrl = ApiEndPoint.baseUrl;

  /// Upload files (images) to the server
  /// Takes a list of file paths and uploads them
  /// Returns a list of uploaded file URLs
  Future<List<String>> uploadFiles(List<String> filePaths) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login first.');
      }

      final url = Uri.parse('$baseUrl/auth/upload');
      debugPrint('Uploading ${filePaths.length} files to: $url');

      // Create multipart request
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token';

      // Add files to the request
      for (int i = 0; i < filePaths.length; i++) {
        final file = File(filePaths[i]);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'images', // Field name - API expects 'images' as array
              file.path,
            ),
          );
          debugPrint('Added file: ${file.path}');
        } else {
          debugPrint('File not found: ${file.path}');
        }
      }

      // Send the request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Upload request timeout');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint('Upload response status: ${response.statusCode}');
      debugPrint('Upload response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        
        if (json['success'] == true) {
          final List<dynamic> fileUrls = json['data'] ?? [];
          final uploadedUrls = fileUrls.map((url) => url.toString()).toList();
          debugPrint('Successfully uploaded ${uploadedUrls.length} files');
          return uploadedUrls;
        } else {
          throw Exception(json['message'] ?? 'Upload failed');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading files: $e');
      throw Exception('Error uploading files: $e');
    }
  }
}
