import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class TopUpSuccessBottomSheet extends StatelessWidget {
  const TopUpSuccessBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top swipe indicator
          Container(
            width: 45,
            height: 4,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          SizedBox(height: 20),

          // Success UI
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(height: 370, width: 375),

              Image.asset(IconPath.topupdailog, height: 262, width: 223),

              Positioned(
                left: 60,
                top: 40,
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.getAccountScreen());
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.greenAccent,
                    child: Icon(Icons.check, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 25),

          Text(
            "Top Up Successfully",
            style: getTextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),

          SizedBox(height: 8),

          Text(
            "Congratulations! Your balance already\nadded, and please check your balance.",
            textAlign: TextAlign.center,
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),

          SizedBox(height: 30),
        ],
      ),
    );
  }
}
