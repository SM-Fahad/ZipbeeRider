import 'package:ZipBee_Driver/features/auth/login/controller/profile_check_controller.dart';
import 'package:ZipBee_Driver/features/home/controller/home_controller.dart';
import 'package:get/get.dart';

class BottomNavbarController extends GetxController {
  RxInt currentIndex = 0.obs;

  @override
  void onReady() {
    super.onReady();
    _checkProfileStatus();
  }

  void changeTab(int index) {
    final previousIndex = currentIndex.value;
    currentIndex.value = index;

    if (index == 0 && previousIndex != 0) {
      final homeController = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>()
          : Get.put(HomeController(), permanent: true);
      homeController.refreshOrders();
    }
  }

  Future<void> _checkProfileStatus() async {
    final profileCheckController = Get.isRegistered<ProfileCheckController>()
        ? Get.find<ProfileCheckController>()
        : Get.put(ProfileCheckController(autoCheckOnInit: false));

    await profileCheckController.checkProfile(
      showLoader: false,
      navigateOnSuccess: false,
    );
  }
}
