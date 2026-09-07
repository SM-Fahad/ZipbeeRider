import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/utils/constants/appcolors.dart';
import '../../../../core/utils/constants/image_path.dart';
import '../controller/forget_verification_controller.dart';
import '../widgets/input_box_widget.dart';
import '../widgets/verify_button_widget.dart';

class ForgetVerificationScreen extends StatelessWidget {
  const ForgetVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ForgetVerificationController controller = Get.put(
      ForgetVerificationController(),
    );

    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: media.size.width * 0.07),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: media.size.height * 0.02),

              /// BACK BUTTON
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: media.size.width * 0.1,
                  height: media.size.width * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black87),
                ),
              ),

              /// IMAGE
              Center(
                child: Image.asset(
                  ImagePath.background2,
                  height: media.size.height * 0.25,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: media.size.height * 0.04),

              /// TEXT SECTION
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Verification Code',
                    style: getTextStyle(
                      fontSize: media.size.width * 0.05,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: media.size.height * 0.02),
                  Text(
                    'Enter the OTP sent to',
                    style: getTextStyle(
                      fontSize: media.size.width * 0.035,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: media.size.height * 0.01),

                  /// EMAIL OR PHONE
                  Obx(() {
                    final value = controller.email.value.isNotEmpty
                        ? controller.email.value
                        : controller.phone.value;

                    return Text(
                      value,
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    );
                  }),
                ],
              ),

              SizedBox(height: media.size.height * 0.05),

              /// OTP INPUT
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return ForgetInputBoxField(
                      context: context,
                      controller: controller,
                      index: index,
                      screenWidth: media.size.width,
                    );
                  }),
                ),
              ),

              SizedBox(height: media.size.height * 0.03),

              /// RESEND TIMER
              Obx(() {
                return Center(
                  child: controller.canResend
                      ? GestureDetector(
                          onTap: controller.resendCode,
                          child: Text(
                            'Resend code',
                            style: getTextStyle(
                              color: AppColors.primaryButtonColor,
                              fontWeight: FontWeight.w600,
                              fontSize: media.size.width * 0.030,
                            ),
                          ),
                        )
                      : RichText(
                          text: TextSpan(
                            style: getTextStyle(
                              fontSize: media.size.width * 0.030,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                            children: [
                              const TextSpan(text: 'Resend code in '),
                              TextSpan(
                                text: '${controller.secondsLeft.value}s',
                                style: getTextStyle(
                                  color: AppColors.primaryButtonColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                );
              }),

              SizedBox(height: media.size.height * 0.08),

              /// VERIFY BUTTON
              ForgetVerifyButton(controller: controller, media: media),
            ],
          ),
        ),
      ),
    );
  }
}
