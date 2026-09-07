import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/auth/login/controller/profile_check_controller.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:get/get.dart';


class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await SharedPreferencesHelper.checkFirstRun();
    // ✅ Correct method
    final bool isLogin = await SharedPreferencesHelper.isLoggedIn();

    // Splash delay
    await Future.delayed(const Duration(seconds: 2));

    if (isLogin) {
      final profileCheckController = Get.isRegistered<ProfileCheckController>()
          ? Get.find<ProfileCheckController>()
          : Get.put(ProfileCheckController(autoCheckOnInit: false));
      await profileCheckController.checkProfile(showLoader: false);
    } else {
      Get.offAllNamed(AppRoutes.onboardingScreen);
    }
  }
}

