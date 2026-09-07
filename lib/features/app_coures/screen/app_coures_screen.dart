// ignore_for_file: deprecated_member_use

import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/app_coures/controller/app_coures_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AppCouresScreen extends StatelessWidget {
  final AppCouresController ctrl = Get.put(AppCouresController());

  AppCouresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(w),
      body: SafeArea(
        child: Obx(() {
          // Loading state
          if (ctrl.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          // Error state
          if (ctrl.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading quiz',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(ctrl.errorMessage.value, textAlign: TextAlign.center),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: ctrl.goBackToQuizSelection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                        ),
                        child: Text('Go Back'),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: ctrl.refreshQuestions,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (ctrl.questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No questions available'),
                ],
              ),
            );
          }

          // Quiz content
          final index = ctrl.currentIndex.value;
          final question = ctrl.questions[index];
          final total = ctrl.questions.length;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.04,
              vertical: h * 0.015,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuestionSteps(total, index, w, h),

                SizedBox(height: h * 0.02),

                /// Question Text
                Text(
                  question['question'] as String,
                  style: getTextStyle(
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryFontColor,
                  ),
                ),

                SizedBox(height: h * 0.02),

                /// Options
                Expanded(
                  child: ListView.separated(
                    itemCount: (question['options'] as List).length,
                    separatorBuilder: (_, __) => SizedBox(height: h * 0.015),
                    itemBuilder: (context, i) {
                      final option = (question['options'] as List<String>)[i];
                      final letter = String.fromCharCode(65 + i);
                      final isSelected = ctrl.selectedOption.value == option;

                      return GestureDetector(
                        onTap: () => ctrl.selectOption(option),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: h * 0.015,
                            horizontal: w * 0.04,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.onboardingIndicatorActive
                                    .withOpacity(0.25)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.onboardingIndicatorActive
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: w * 0.045,
                                backgroundColor: isSelected
                                    ? AppColors.onboardingIndicatorActive
                                    : Colors.grey[300],
                                child: Text(
                                  letter,
                                  style: getTextStyle(
                                    fontSize: w * 0.04,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                              SizedBox(width: w * 0.04),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: w * 0.04,
                                    color: AppColors.primaryFontColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: h * 0.02),

                _buildBottomButtons(context, index, w, h),

                SizedBox(height: h * 0.03),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// -------------------------------------------------------------------
  /// APP BAR
  /// -------------------------------------------------------------------
  AppBar _buildAppBar(double w) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryFontColor),
        onPressed: () => Get.back(),
      ),
      title: Text(
        "App Course",
        style: getTextStyle(
          color: Colors.black,
          fontSize: w * 0.045,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  /// -------------------------------------------------------------------
  /// QUESTION STEPS (TOP DOTS)
  /// -------------------------------------------------------------------
  Widget _buildQuestionSteps(int total, int index, double w, double h) {
    return SizedBox(
      height: h * 0.12,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: total,
        separatorBuilder: (_, __) => SizedBox(width: w * 0.05),
        itemBuilder: (context, i) {
          bool isActive = i == index;

          return Column(
            children: [
              Container(
                width: w * 0.12,
                height: w * 0.12,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.onboardingIndicatorActive
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "${i + 1}",
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? AppColors.primaryFontColor
                          : Colors.grey[700],
                    ),
                  ),
                ),
              ),
              SizedBox(height: h * 0.006),
              Container(
                width: w * 0.15,
                height: h * 0.008,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: isActive
                      ? AppColors.onboardingIndicatorActive
                      : Colors.grey[300],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// -------------------------------------------------------------------
  /// PREVIOUS - NEXT BUTTONS
  /// -------------------------------------------------------------------
  Widget _buildBottomButtons(
    BuildContext context,
    int index,
    double w,
    double h,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// Previous Button
        ElevatedButton(
          onPressed: index > 0 ? ctrl.previousQuestion : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: Size(w * 0.42, h * 0.055),
          ),
          child: Text(
            "Previous",
            style: getTextStyle(color: Colors.grey, fontSize: w * 0.038),
          ),
        ),

        /// Next Button
        OutlinedButton(
          onPressed: ctrl.selectedOption.value.isNotEmpty
              ? () => _handleNext(context)
              : null,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.amber, width: 2),
            backgroundColor: ctrl.selectedOption.value.isNotEmpty
                ? AppColors.onboardingIndicatorActive
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: Size(w * 0.42, h * 0.055),
          ),
          child: Text(
            "Next",
            style: getTextStyle(
              color: ctrl.selectedOption.value.isNotEmpty
                  ? Colors.black
                  : Colors.grey,
              fontSize: w * 0.038,
            ),
          ),
        ),
      ],
    );
  }

  /// -------------------------------------------------------------------
  /// NEXT LOGIC
  /// -------------------------------------------------------------------
  void _handleNext(BuildContext context) {
    ctrl.nextQuestion();
  }
}
