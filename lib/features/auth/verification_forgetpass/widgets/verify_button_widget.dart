import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/utils/constants/appcolors.dart';
import '../controller/forget_verification_controller.dart';

class ForgetVerifyButton extends StatelessWidget {
  const ForgetVerifyButton({
    super.key,
    required this.controller,
    required this.media,
  });

  final ForgetVerificationController controller;
  final MediaQueryData media;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canVerify = controller.canVerify;
      final isVerifying = controller.isVerifying.value;
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canVerify ? controller.verifyCode : null,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: media.size.height * 0.02),
            backgroundColor: canVerify
                ? AppColors.primaryButtonColor
                // ignore: deprecated_member_use
                : AppColors.primaryButtonColor.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isVerifying
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Verify Now',
                  style: getTextStyle(
                    color: Colors.black,
                    fontSize: media.size.width * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      );
    });
  }
}
