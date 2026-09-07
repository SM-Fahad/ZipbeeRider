import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
import 'package:ZipBee_Driver/features/records/controller/records_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class RecordsScreen extends StatelessWidget {
  RecordsScreen({super.key});

  final controller = Get.put(RecordsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.onboardingIndicatorActive,
        elevation: 0,
        // leading: IconButton(
        //   onPressed: () => Get.back(),
        //   icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
        // ),
        title: Text(
          "Records",
          style: getTextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // ---- Ongoing ----
            recordButton(
              icon: IconPath.on_going,
              text: "On-going",
              onTap: controller.goToOnGoing,
            ),
            SizedBox(height: 20),

            // ---- Completed ----
            recordButton(
              icon: IconPath.completed,
              text: "Completed",
              onTap: controller.goToCompleted,
            ),
            SizedBox(height: 20),

            // ---- Cancelled ----
            recordButton(
              icon: IconPath.cancelled,
              text: "Cancelled",
              onTap: controller.goToCancelled,
            ),
            SizedBox(height: 20),

            // ---- Income ----
            recordButton(
              icon: IconPath.income,
              text: "Income",
              onTap: controller.goToIncome,
            ),
          ],
        ),
      ),
    );
  }

  // reusable button
  Widget recordButton({
    required dynamic icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryButtonColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon is IconData
                ? Icon(icon, color: Colors.black, size: 28)
                : Image.asset(icon, height: 32, width: 32),
            SizedBox(height: 5),
            Text(
              text,
              style: getTextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
