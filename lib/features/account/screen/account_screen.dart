import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/image_path.dart';
import 'package:ZipBee_Driver/features/account/controller/account_controller.dart';
import 'package:ZipBee_Driver/features/account_vehicle/screen/view_vehicle_screen.dart';
import 'package:ZipBee_Driver/features/auth/driver_documents/screen/driver_documents_screen.dart';
import 'package:ZipBee_Driver/features/payment_method/screen/payment_method_screen.dart';
import 'package:ZipBee_Driver/features/payment_method/controller/payment_method_controller.dart';
import 'package:ZipBee_Driver/features/profile/screen/profile_screen.dart';
import 'package:ZipBee_Driver/features/profile/controller/profile_controller.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/constants/appcolors.dart';
import '../../support/user_support/screen/support_screen.dart';

class AccountScreen extends StatelessWidget {
  final AccountController controller = Get.isRegistered<AccountController>()
      ? Get.find<AccountController>()
      : Get.put(AccountController());

  AccountScreen({super.key});

  // Helper to get rank image path
  String getRankImage(String rank) {
    switch (rank.toUpperCase()) {
      case "BRONZE":
        return ImagePath.bronze;
      case "SILVER":
        return ImagePath.silver;
      case "GOLD":
        return ImagePath.gold;
      case "PLATINUM":
        return ImagePath.diamond;
      default:
        return ImagePath.bronze;
    }
  }

  Color getRankTextColor(String rank) {
    switch (rank.toUpperCase()) {
      case "PLATINUM":
        return Colors.white;
      case "BRONZE":
      case "SILVER":
      case "GOLD":
      default:
        return AppColors.fontColor;
    }
  }

  Color getRankCardColor(String rank) {
    switch (rank.toUpperCase()) {
      case "SILVER":
        return AppColors.silverColor;
      case "GOLD":
        return AppColors.goldColor;
      case "PLATINUM":
        return AppColors.platinumColor;
      case "BRONZE":
      default:
        return AppColors.bronzeColor;
    }
  }

  Future<void> _onRefresh() async {
    await controller.fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: Obx(() {
            final rank = controller.rank.value;
            final textColor = getRankTextColor(rank);
            final cardColor = getRankCardColor(rank);

            return Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.04,
                    vertical: h * 0.02,
                  ),
                  color: cardColor,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: w * 0.09,
                        backgroundImage: controller.driverPhoto.value.isNotEmpty
                            ? NetworkImage(controller.driverPhoto.value)
                            : AssetImage(ImagePath.profile) as ImageProvider,
                      ),
                      SizedBox(width: w * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.riderName.value,
                              style: TextStyle(
                                fontSize: w * 0.045,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  size: w * 0.04,
                                  color: textColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "${controller.followers.value} Followers",
                                  style: TextStyle(
                                    fontSize: w * 0.035,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_pin,
                                  size: w * 0.04,
                                  color: textColor,
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    controller.location.value,
                                    style: TextStyle(
                                      fontSize: w * 0.035,
                                      color: textColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: w * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                getRankImage(rank),
                                height: w * 0.08,
                                width: w * 0.08,
                              ),
                              SizedBox(width: 6),
                              Text(
                                rank,
                                style: getTextStyle(
                                  fontSize: w * 0.04,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: w * 0.05,
                                color: textColor,
                              ),
                              SizedBox(width: 4),
                              Text(
                                controller.rating.value.toString(),
                                style: getTextStyle(
                                  fontSize: w * 0.04,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: h * 0.03),
                Container(
                  width: w * 0.9,
                  padding: EdgeInsets.symmetric(vertical: h * 0.025),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Total Balance",
                        style: TextStyle(
                          fontSize: w * 0.04,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "\$${controller.totalBalance.value.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: w * 0.07,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: h * 0.03),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: w < 380 ? 1.2 : 1.4,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: [
                        menuButton(
                          "Profile",
                          Icons.person,
                          cardColor,
                          textColor,
                          () {
                            if (Get.isRegistered<ProfileController>()) {
                              Get.find<ProfileController>().getProfileData();
                            }
                            Get.to(() => ProfileScreen())?.then((_) => controller.fetchProfile());
                          },
                        ),
                        menuButton(
                          "Wallet",
                          Icons.account_balance_wallet,
                          cardColor,
                          textColor,
                          () {
                            if (Get.isRegistered<PaymentMethodController>()) {
                              Get.find<PaymentMethodController>().getWalletBalance();
                            }
                            if (Get.isRegistered<ProfileController>()) {
                              Get.find<ProfileController>().getProfileData();
                            }
                            Get.to(() => PaymentMethodScreen())?.then((_) => controller.fetchProfile());
                          },
                        ),
                        menuButton(
                          "Vehicle",
                          Icons.directions_car,
                          cardColor,
                          textColor,
                          () => Get.to(() => ViewVehicleScreen())?.then((_) => controller.fetchProfile()),
                        ),
                        menuButton(
                          "Documents",
                          Icons.description,
                          cardColor,
                          textColor,
                          () => Get.to(() => DriverDocumentsScreen())?.then((_) => controller.fetchProfile()),
                        ),
                        menuButton(
                          "Support",
                          Icons.headset_mic,
                          cardColor,
                          textColor,
                          () => Get.to(() => SupportScreen())?.then((_) => controller.fetchProfile()),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: h * 0.02),
                if (controller.canShowAutoPopupPermission) ...[
                  Container(
                    width: w * 0.9,
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.04,
                      vertical: h * 0.018,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Auto Popup Permission",
                            style: TextStyle(
                              fontSize: w * 0.04,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        Obx(
                          () => Switch(
                            value: controller.isAutoPopupEnabled.value,
                            onChanged: controller.isAutoPopupUpdating.value
                                ? null
                                : controller.updateAutoPopupPermission,
                            activeThumbColor: Colors.green,
                            inactiveThumbColor: Colors.grey,
                            inactiveTrackColor: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                ],
                GestureDetector(
                  onTap: () async {
                    await controller.logout();
                    Get.toNamed(AppRoutes.getLoginSignupScreen());
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: h * 0.02, top: h * 0.004),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: w * 0.05),
                        SizedBox(width: 6),
                        Text(
                          "Sign Out",
                          style: TextStyle(
                            fontSize: w * 0.04,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget menuButton(
    String title,
    IconData icon,
    Color cardColor,
    Color textColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: textColor),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
