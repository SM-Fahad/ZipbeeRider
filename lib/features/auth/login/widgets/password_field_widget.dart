import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;

  const PasswordField({super.key, this.controller, this.hintText});

  @override
  Widget build(BuildContext context) {
    final RxBool isVisible = false.obs;

    return Obx(
      () => Container(
        height: 52,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.subtitleFontColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: TextField(
            controller: controller,
            obscureText: !isVisible.value,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hintText ?? '********',
              border: InputBorder.none,
              isDense: true,
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible.value ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey.shade700,
                ),
                onPressed: () => isVisible.value = !isVisible.value,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
