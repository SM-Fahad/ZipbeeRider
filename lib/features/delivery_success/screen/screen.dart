import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/constants/image_path.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/controller.dart';

class DeliverySuccessScreen extends StatelessWidget {
  final DeliverySuccessController ctrl = Get.put(DeliverySuccessController());

  DeliverySuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
          child: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            backgroundColor: AppColors.primaryButtonColor,
            centerTitle: true,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 76),
                    Image.asset(ImagePath.successImage),
                    SizedBox(height: 25),

                    Text(
                      'Delivery Successful',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryFontColor,
                      ),
                    ),
                    SizedBox(height: 6),

                    Obx(
                      () => Text(
                        'Item has been Delivery Successful, ${ctrl.userName.value}!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),

                    SizedBox(height: 35),

                    // Don't remove commented codes
                    // Text(
                    //   'Rate Customer',
                    //   style: TextStyle(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.w600,
                    //     color: AppColors.primaryFontColor,
                    //   ),
                    // ),
                    // SizedBox(height: 10),

                    // Obx(
                    //   () => Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: List.generate(5, (index) {
                    //       return IconButton(
                    //         onPressed: () => ctrl.updateRating(index + 1),
                    //         icon: Icon(
                    //           index < ctrl.rating.value
                    //               ? Icons.star
                    //               : Icons.star_border,
                    //           color: AppColors.subtitleFontColor,
                    //           size: 24,
                    //         ),
                    //       );
                    //     }),
                    //   ),
                    // ),

                    // SizedBox(height: 50),

                    // Container(
                    //   padding: EdgeInsets.symmetric(
                    //     vertical: 10,
                    //     horizontal: 12,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(12),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         // ignore: deprecated_member_use
                    //         color: Colors.grey.withOpacity(0.3),
                    //         spreadRadius: 2,
                    //         blurRadius: 6,
                    //         offset: Offset(0, 3),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       Image.asset(
                    //         IconPath.message,
                    //         color: AppColors.primaryFontColor,
                    //         height: 20,
                    //         width: 20,
                    //       ),
                    //       SizedBox(width: 8),
                    //       Text(
                    //         'Add Feedback',
                    //         style: TextStyle(
                    //           fontSize: 16,
                    //           fontWeight: FontWeight.w500,
                    //           color: AppColors.primaryFontColor,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.bottomNavbarScreen);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryFontColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
