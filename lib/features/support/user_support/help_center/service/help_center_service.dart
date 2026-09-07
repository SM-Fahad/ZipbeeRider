import 'dart:convert';
import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/support/user_support/help_center/model/about_us_model.dart';
import 'package:ZipBee_Driver/features/support/user_support/help_center/model/content_management_model.dart';
import 'package:ZipBee_Driver/features/support/user_support/help_center/model/help_article_model.dart';
import 'package:http/http.dart' as http;

class HelpCenterService {
  /// Fetch About Us data from API
  Future<AboutUsResponse?> fetchAboutUs() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final headers = {
        'accept': '*/*',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse(ApiEndPoint.aboutUs),
        headers: headers,
      );

      print('About Us Response: ${response.statusCode}');
      print('About Us Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final aboutUsResponse = AboutUsResponse.fromJson(json);

        // Filter by faq_for == RAIDER
        final AboutUs = aboutUsResponse.data
            .where((item) => item.faqFor.toUpperCase() == 'RAIDER')
            .toList();

        return AboutUsResponse(
          success: aboutUsResponse.success,
          message: aboutUsResponse.message,
          data: AboutUs,
        );
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in fetchAboutUs: $e');
      return null;
    }
  }

  /// Fetch Help Articles from API
  Future<HelpArticleResponse?> fetchHelpArticles() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final headers = {
        'accept': '*/*',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse(ApiEndPoint.helpArticles),
        headers: headers,
      );

      print('Help Articles Response: ${response.statusCode}');
      print('Help Articles Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final articleResponse = HelpArticleResponse.fromJson(json);

        // Filter by faq_for == RAIDER
        final Articles = articleResponse.data
            .where((item) => item.faqFor.toUpperCase() == 'RAIDER')
            .toList();

        return HelpArticleResponse(
          success: articleResponse.success,
          message: articleResponse.message,
          data: Articles,
        );
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in fetchHelpArticles: $e');
      return null;
    }
  }

  /// Fetch Content Management data from API
  Future<ContentManagementResponse?> fetchContentManagement() async {
    try {
      final headers = {'accept': '*/*'};

      final response = await http.get(
        Uri.parse(ApiEndPoint.contentManagement),
        headers: headers,
      );

      print('Content Management Response: ${response.statusCode}');
      print('Content Management Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final contentResponse = ContentManagementResponse.fromJson(json);

        // Filter by faq_for == RAIDER
        final Content = contentResponse.data
            .where((item) => item.faqFor.toUpperCase() == 'RAIDER')
            .toList();

        return ContentManagementResponse(
          success: contentResponse.success,
          message: contentResponse.message,
          data: Content,
        );
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in fetchContentManagement: $e');
      return null;
    }
  }
}
