import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/driver_preference/controller/driver_preference_controller.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class TowButtonSection extends StatelessWidget {
  const TowButtonSection({super.key, required this.ctrl});

  final DriverPreferenceController ctrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        // Don't delete cancel button
        // Expanded(
        //   child: OutlinedButton(
        //     onPressed: () {
        //       ctrl.cancelOrder();
        //     },
        //     style: OutlinedButton.styleFrom(
        //       side: BorderSide(color: Colors.red, width: 1),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(6),
        //       ),
        //       padding: EdgeInsets.symmetric(vertical: 8),
        //     ),
        //     child: Text(
        //       "Cancel",
        //       style: TextStyle(
        //         color: Colors.red,
        //         fontWeight: FontWeight.w600,
        //         fontSize: 14,
        //       ),
        //     ),
        //   ),
        // ),
        // SizedBox(width: 75),
        Expanded(
          child: Obx(
            () => ElevatedButton(
              onPressed: ctrl.isOnline.value
                  ? () {
                      Get.toNamed(AppRoutes.getBottomNavbarScreen());
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ctrl.isOnline.value
                    ? AppColors.onboardingIndicatorActive
                    : Colors.grey.shade300,
                foregroundColor: ctrl.isOnline.value
                    ? AppColors.primaryFontColor
                    : Colors.grey.shade600,
                elevation: ctrl.isOnline.value ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
              child: const Text(
                "Done",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
