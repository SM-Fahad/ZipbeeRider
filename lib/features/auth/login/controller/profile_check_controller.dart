import 'dart:convert';

import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:ZipBee_Driver/core/services/socket_service.dart';
import 'package:ZipBee_Driver/features/home/controller/home_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

enum ProfileCheckAction { none, registration, quiz, payment }

class ProfileCheckController extends GetxController {
  ProfileCheckController({this.autoCheckOnInit = true});

  final bool autoCheckOnInit;
  final isLoading = true.obs;
  final isSigningOut = false.obs;
  final username = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;
  final statusTitle = 'Checking your profile'.obs;
  final statusMessage =
      'Please wait while we review your account information.'.obs;
  final primaryButtonText = ''.obs;
  final activeAction = ProfileCheckAction.none.obs;
  final rank = 'BRONZE'.obs;

  @override
  void onInit() {
    super.onInit();
    if (autoCheckOnInit) {
      checkProfile();
    }
  }

  bool get showPrimaryButton => activeAction.value != ProfileCheckAction.none;

  Future<void> checkProfile({
    bool showLoader = true,
    bool navigateOnSuccess = true,
  }) async {
    if (showLoader) {
      isLoading.value = true;
    }

    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        await _goToLogin();
        return;
      }

      final response = await http.get(
        Uri.parse(ApiEndPoint.getProfile),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        if (_shouldForceSignOut(response)) {
          await signOut(callApi: false);
          return;
        }

        _setStatus(
          title: 'Login Again',
          message:
              'We could not verify your profile right now. Please tap Re-Check.',
        );
        _showProfileCheckScreenIfNeeded();
        return;
      }

      final decoded = jsonDecode(response.body);
      Map<String, dynamic> data;
      if (decoded is Map<String, dynamic>) {
        if (decoded['data'] is Map<String, dynamic>) {
          data = Map<String, dynamic>.from(decoded['data']);
        } else {
          data = Map<String, dynamic>.from(decoded);
        }
      } else {
        data = <String, dynamic>{};
      }
      await processProfileData(data, navigateOnSuccess: navigateOnSuccess);
    } catch (e) {
      debugPrint('PROFILE CHECK ERROR: $e');
      _setStatus(
        title: 'Profile check failed',
        message: 'Something went wrong. Please tap Re-Check.',
      );
      _showProfileCheckScreenIfNeeded();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> processProfileData(
    Map<String, dynamic>? data, {
    bool navigateOnSuccess = true,
  }) async {
    if (data == null || data.isEmpty) {
      _setStatus(
        title: 'Profile check failed',
        message: 'Something went wrong. Please tap Re-Check.',
      );
      _showProfileCheckScreenIfNeeded();
      return;
    }

    isLoading.value = true;

    try {
      final raiderProfile = Map<String, dynamic>.from(
        data['raiderProfile'] ?? <String, dynamic>{},
      );
      final registrations = List<dynamic>.from(
        raiderProfile['registrations'] ?? const [],
      );
      final quizzes = List<dynamic>.from(
        raiderProfile['raiderQuizzes'] ?? const [],
      );
      final roles = List<dynamic>.from(data['roles'] ?? const []);

      username.value = data['username']?.toString() ?? '';
      email.value = data['email']?.toString() ?? '';
      phone.value = data['phone']?.toString() ?? '';
      rank.value = raiderProfile['rank']?.toString() ?? 'BRONZE';

      final userId =
          raiderProfile['userId']?.toString() ?? data['id']?.toString();
      if (userId != null && userId.isNotEmpty) {
        await SharedPreferencesHelper.saveUserId(userId);
      }

      final raiderId = raiderProfile['id']?.toString();
      if (raiderId != null && raiderId.isNotEmpty) {
        await SharedPreferencesHelper.saveRaiderId(raiderId);
      }

      final isRaider = roles.any(
        (role) =>
            role is Map && role['name']?.toString().toUpperCase() == 'RAIDER',
      );

      if (!isRaider) {
        EasyLoading.showError('You are not a RAIDER');
        await signOut(callApi: false);
        return;
      }

      if (registrations.isEmpty) {
        _setStatus(
          title: 'Registration Required',
          message:
              'You did not complete your registration. Please complete your registration.',
          action: ProfileCheckAction.registration,
          actionText: 'Complete Registration',
        );
        _showProfileCheckScreenIfNeeded();
        return;
      }

      final verificationStatus =
          raiderProfile['raider_verificationFromAdmin']
              ?.toString()
              .toUpperCase() ??
          '';

      if (verificationStatus != 'APPROVED') {
        _setStatus(
          title: 'Waiting For Admin Approval',
          message: 'Admin has not approved your registration yet. Please wait.',
        );
        _showProfileCheckScreenIfNeeded();
        return;
      }

      if (quizzes.isEmpty) {
        _setStatus(
          title: 'Quiz Required',
          message: 'Please participate in the quiz to continue.',
          action: ProfileCheckAction.quiz,
          actionText: 'Participate In Quiz',
        );
        _showProfileCheckScreenIfNeeded();
        return;
      }

      final highestScore = quizzes
          .map(_extractScore)
          .fold<int>(0, (highest, score) => score > highest ? score : highest);
      final hasPerfectScore = quizzes.any((quiz) => _extractScore(quiz) >= 100);

      if (!hasPerfectScore) {
        _setStatus(
          title: 'Quiz Not Completed',
          message:
              'Your highest score is $highestScore. You need 100 to continue.',
          action: ProfileCheckAction.quiz,
          actionText: 'Try Again',
        );
        _showProfileCheckScreenIfNeeded();
        return;
      }

      final isDepositMade = raiderProfile['is_deposit_made'] ?? false;
      if (!isDepositMade) {
        _setStatus(
          title: 'Payment Required',
          message:
              'You didn\'t pay background check fee. Please pay now to continue.',
          action: ProfileCheckAction.payment,
          actionText: 'Pay Now',
        );
        _showProfileCheckScreenIfNeeded();
        return;
      }

      if (navigateOnSuccess) {
        final homeCtrl = Get.isRegistered<HomeController>()
            ? Get.find<HomeController>()
            : Get.put(HomeController(), permanent: true);
        homeCtrl.connectSocket();

        Get.offAllNamed(
          AppRoutes.driverPreferenceScreen,
          arguments: rank.value,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handlePrimaryAction() async {
    switch (activeAction.value) {
      case ProfileCheckAction.registration:
        await Get.toNamed(AppRoutes.riderDetailsScreen);
        break;
      case ProfileCheckAction.quiz:
        await Get.toNamed(AppRoutes.appQuizScreen);
        break;
      case ProfileCheckAction.payment:
        await Get.toNamed(AppRoutes.walletScreen);
        break;
      case ProfileCheckAction.none:
        break;
    }
  }

  Future<void> recheckProfile() async {
    await checkProfile();
  }

  Future<void> signOut({bool callApi = true}) async {
    if (isSigningOut.value) {
      return;
    }

    isSigningOut.value = true;

    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      if (callApi && token != null && token.isNotEmpty) {
        await http.post(
          Uri.parse(ApiEndPoint.logOut),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      }
    } catch (e) {
      debugPrint('SIGN OUT ERROR: $e');
    } finally {
      if (Get.isRegistered<HomeController>()) {
        final homeCtrl = Get.find<HomeController>();
        homeCtrl.isOnline.value = false;
        homeCtrl.clearOrdersState();
      }
      SocketService().disconnect();

      await SharedPreferencesHelper.clearAllData();
      isSigningOut.value = false;
      Get.offAllNamed(AppRoutes.loginSignupScreen);
    }
  }

  int _extractScore(dynamic quiz) {
    if (quiz is! Map) {
      return 0;
    }

    final score = quiz['score'];

    if (score is int) {
      return score;
    }

    if (score is double) {
      return score.toInt();
    }

    return int.tryParse(score?.toString() ?? '') ?? 0;
  }

  bool _isExpiredTokenResponse(http.Response response) {
    if (response.statusCode == 401) {
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          final message = body['message']?.toString().trim().toLowerCase();
          final error = body['error']?.toString().trim().toLowerCase();

          if (message == 'invalid or expired token' ||
              error == 'unauthorized') {
            return true;
          }
        }
      } catch (_) {
        return true;
      }
    }

    return false;
  }

  bool _shouldForceSignOut(http.Response response) {
    if (_isExpiredTokenResponse(response)) {
      return true;
    }

    if (response.statusCode == 403) {
      return true;
    }

    try {
      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) {
        return false;
      }

      final topLevelMessage = body['message']?.toString().trim().toLowerCase();
      final error = body['error'];
      final errorMap = error is Map<String, dynamic>
          ? error
          : error is Map
          ? Map<String, dynamic>.from(error)
          : <String, dynamic>{};
      final errorMessage = errorMap['message']?.toString().trim().toLowerCase();
      final nestedResponse = errorMap['response'];
      final nestedResponseMap = nestedResponse is Map<String, dynamic>
          ? nestedResponse
          : nestedResponse is Map
          ? Map<String, dynamic>.from(nestedResponse)
          : <String, dynamic>{};
      final nestedMessage = nestedResponseMap['message']
          ?.toString()
          .trim()
          .toLowerCase();
      final nestedStatusCode = nestedResponseMap['statusCode'];

      final isUserMissing =
          response.statusCode == 404 &&
          (topLevelMessage == 'failed to fetch user' ||
              errorMessage == 'user not found' ||
              nestedMessage == 'user not found' ||
              nestedStatusCode == 404);

      if (isUserMissing) {
        return true;
      }
    } catch (_) {
      return false;
    }

    return false;
  }

  Future<void> _goToLogin() async {
    await SharedPreferencesHelper.clearAllData();
    Get.offAllNamed(AppRoutes.loginSignupScreen);
  }

  void _showProfileCheckScreenIfNeeded() {
    if (Get.currentRoute != AppRoutes.profileCheckScreen) {
      Get.offAllNamed(AppRoutes.profileCheckScreen);
    }
  }

  void _setStatus({
    required String title,
    required String message,
    ProfileCheckAction action = ProfileCheckAction.none,
    String actionText = '',
  }) {
    statusTitle.value = title;
    statusMessage.value = message;
    activeAction.value = action;
    primaryButtonText.value = actionText;
  }
}
