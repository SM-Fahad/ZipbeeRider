import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:flutter/material.dart';

class StepBox extends StatelessWidget {
  const StepBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 4),
            height: 6,
            decoration: BoxDecoration(
              color: index == 0
                  ? AppColors.onboardingIndicatorActive
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }),
    );
  }
}
