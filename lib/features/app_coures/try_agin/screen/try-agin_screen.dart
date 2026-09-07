import 'package:ZipBee_Driver/core/common/widgets/custom_app_bar.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/app_coures/try_agin/controller/try_agin_controller.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class TryAginScreen extends StatelessWidget {
  const TryAginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TryAginController ctrl = Get.put(TryAginController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: CustomAppBar(lable: 'App Quiz', back: null),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 30),
            buildScoreCircle(ctrl),
            SizedBox(height: 30),
            buildMessage(ctrl),
            Spacer(),
            buildTryAgainButton(ctrl),
          ],
        ),
      ),
    );
  }

  Widget buildScoreCircle(TryAginController ctrl) {
    return Obx(
      () => Container(
        width: 152,
        height: 152,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.subtitleFontColor,
          border: Border.all(color: Colors.grey, width: 6),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Score',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              ctrl.score.value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMessage(TryAginController ctrl) {
    return Obx(
      () => Text(
        ctrl.message.value,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildTryAgainButton(TryAginController ctrl) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Get.offAllNamed(AppRoutes.getAppCouresScreen());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.subtitleFontColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Try Again',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
