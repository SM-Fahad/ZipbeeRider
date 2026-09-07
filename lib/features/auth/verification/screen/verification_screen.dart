import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/constants/image_path.dart';
import 'package:ZipBee_Driver/features/auth/verification/controller/verification_controller.dart';
import 'package:ZipBee_Driver/features/auth/verification/widgets/input_box_widget.dart';
import 'package:ZipBee_Driver/features/auth/verification/widgets/verify_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VerificationController controller = Get.put(VerificationController());
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: media.size.width * 0.07),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: media.size.height * 0.02),

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

              SizedBox(height: media.size.height * 0.02),

              Center(
                child: Image.asset(
                  ImagePath.background2,
                  height: media.size.height * 0.25,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: media.size.height * 0.04),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Email Verification',
                      style: getTextStyle(
                        fontSize: media.size.width * 0.05,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: media.size.height * 0.02),
                    Text(
                      'Enter your OTP here',
                      style: getTextStyle(
                        fontSize: media.size.width * 0.035,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: media.size.height * 0.01),

                    Obx(() {
                      return Text(
                        'OTP sent to ${controller.email.value}',
                        style: getTextStyle(
                          fontSize: media.size.width * 0.029,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }),
                  ],
                ),
              ),

              SizedBox(height: media.size.height * 0.05),

              /// OTP Input Fields
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return InputBoxField(
                      context: context,
                      controller: controller,
                      index: index,
                      screenWidth: media.size.width,
                    );
                  }),
                ),
              ),

              SizedBox(height: media.size.height * 0.03),

              /// Resend Timer
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

              /// Verify Button
              VerifyButton(controller: controller, media: media),

              SizedBox(height: media.size.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
