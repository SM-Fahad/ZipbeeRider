import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
import 'package:ZipBee_Driver/features/account/screen/account_screen.dart';
import 'package:ZipBee_Driver/features/bottom_navbar/controller/bottom_navbar_controller.dart';
import 'package:ZipBee_Driver/features/home/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../incentives/screen/incentives_screen.dart';
import '../../records/screen/records_screen.dart';

class BottomNavbarScreen extends StatelessWidget {
  BottomNavbarScreen({super.key});

  final BottomNavbarController controller = Get.put(BottomNavbarController());

  final List<Widget> _screens = [
    HomeScreen(),
    RecordsScreen(),
    IncentiveScreen(),
    AccountScreen(),
  ];

  Widget navIcon(String iconPath, bool isActive) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        isActive
            ? AppColors.onboardingIndicatorActive
            : AppColors.subtitleFontColor,
        BlendMode.srcIn,
      ),
      child: Image.asset(iconPath, width: 24, height: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: _screens[controller.currentIndex.value],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              currentIndex: controller.currentIndex.value,
              onTap: controller.changeTab,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedItemColor: AppColors.onboardingIndicatorActive,
              unselectedItemColor: AppColors.subtitleFontColor,
              showUnselectedLabels: true,
              selectedLabelStyle: getTextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: getTextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: navIcon(
                    IconPath.home,
                    controller.currentIndex.value == 0,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: navIcon(
                    IconPath.records,
                    controller.currentIndex.value == 1,
                  ),
                  label: 'Records',
                ),
                BottomNavigationBarItem(
                  icon: navIcon(
                    IconPath.incentives,
                    controller.currentIndex.value == 2,
                  ),
                  label: 'Incentives',
                ),
                BottomNavigationBarItem(
                  icon: navIcon(
                    IconPath.account,
                    controller.currentIndex.value == 3,
                  ),
                  label: 'Account',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
