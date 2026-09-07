import 'package:ZipBee_Driver/features/auth/rider_details/controller/rider_details_controller.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/utils/constants/iconpath.dart';

class DriverPhoto extends StatelessWidget {
  final RiderDetailsController ctrl;

  const DriverPhoto({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GestureDetector(
        onTap: ctrl.driverPhoto.value == null ? ctrl.pickDriverPhoto : null,
        child: DottedBorder(
          color: Colors.grey.shade400,
          dashPattern: [6, 4],
          borderType: BorderType.RRect,
          radius: Radius.circular(10),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),

            child: ctrl.driverPhoto.value == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(IconPath.gararelly, width: 24, height: 24),
                        SizedBox(height: 6),
                        Text(
                          "Upload a clear photo of yourself",
                          style: getTextStyle(
                            color: Colors.blueAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "(Max. File size: 25 MB)",
                          style: getTextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          ctrl.driverPhoto.value!,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: GestureDetector(
                          onTap: () => ctrl.driverPhoto.value = null,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    });
  }
}
