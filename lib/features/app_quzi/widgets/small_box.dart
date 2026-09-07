import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:flutter/material.dart';

class SmallBox extends StatelessWidget {
  final String iconPath;
  final String title;
  final String description;
  const SmallBox({
    super.key,
    required this.iconPath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(iconPath, height: 44, width: 44),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.fontColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
