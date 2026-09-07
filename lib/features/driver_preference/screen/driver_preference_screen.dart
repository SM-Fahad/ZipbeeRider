// ignore_for_file: deprecated_member_use

import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/driver_preference/controller/driver_preference_controller.dart';
import 'package:ZipBee_Driver/features/driver_preference/widgets/button_widget.dart';
import 'package:ZipBee_Driver/features/google_map/widget/google_map_widget.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverPreferenceScreen extends StatelessWidget {
  DriverPreferenceScreen({super.key});

  final DriverPreferenceController ctrl =
      Get.isRegistered<DriverPreferenceController>()
      ? Get.find<DriverPreferenceController>()
      : Get.put(DriverPreferenceController());
  final String argumentsRank = Get.arguments ?? 'null';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          // leading: IconButton(
          //   icon: Icon(
          //     Icons.arrow_back_ios_new,
          //     color: AppColors.primaryFontColor,
          //   ),
          //   onPressed: () => Get.back(),
          // ),
          centerTitle: true,
          title: Obx(
            () => Text(
              ctrl.isOnline.value ? "Online" : "Offline",
              style: TextStyle(
                color: AppColors.primaryFontColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          actions: [
            Obx(
              () => Switch(
                value: ctrl.isOnline.value,
                onChanged: ctrl.toggleOffline,
                activeThumbColor: Colors.amber,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // ---- REAL MAP AREA ----
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 374,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: const GoogleMapWidget(showZoomButtons: false),
              ),
            ),
          ),

          // ---- CONTENT AREA ----
          Positioned.fill(
            top: 360,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Preference",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 5),
                    Text(
                      "Set your Auto popup and Distance Radius nearby order",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    SizedBox(height: 20), 

                    /// Feed Refresh Rate
                    Obx(
                      () => Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.onboardingIndicatorActive,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(Icons.refresh),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Feed Refresh Rate (sec)",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: TextFormField(
                              controller: ctrl.feedRefreshRateController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onFieldSubmitted: (_) => ctrl.saveFeedRefreshRate(),
                            ),
                          ),
                          if (ctrl.isModified.value || ctrl.isFeedRefreshRateUpdating.value) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: ctrl.isFeedRefreshRateUpdating.value
                                  ? null
                                  : () => ctrl.saveFeedRefreshRate(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.onboardingIndicatorActive,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ctrl.isFeedRefreshRateUpdating.value
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.black,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.check,
                                        size: 18,
                                        color: Colors.black,
                                      ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Auto Popup
                    Obx(
                      () => Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.onboardingIndicatorActive,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(Icons.remove_red_eye),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Auto Popup",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Switch(
                            value: ctrl.isAutoPopup.value,
                            onChanged: ctrl.isAutoPopupUpdating.value
                                ? null
                                : ctrl.toggleAutoPopup,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    /// Distance Radius
                    InkWell(
                      onTap: () => Get.toNamed(
                        AppRoutes.getDistanceRadiusScreen(),
                        arguments: argumentsRank,
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.onboardingIndicatorActive,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.location_on),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Distance Radius",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    /// Bottom Buttons --- Works in Release mode always!
                    TowButtonSection(ctrl: ctrl),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
