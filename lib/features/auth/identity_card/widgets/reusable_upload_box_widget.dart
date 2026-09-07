import 'dart:io';

import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
import 'package:ZipBee_Driver/features/auth/identity_card/controller/identity_card_controller.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';


class ReusableUploadBox extends StatelessWidget {
  const ReusableUploadBox({
    super.key,
    required this.ctrl,
    required this.title,
    required this.fileRef,
  });

  final IdentityCardController ctrl;
  final String title;
  final Rx<File?> fileRef;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: fileRef.value == null ? () => ctrl.pickImage(fileRef) : null,
        child: DottedBorder(
          color: Colors.grey.shade400,
          strokeWidth: 1.2,
          dashPattern: [6, 4],
          borderType: BorderType.RRect,
          radius: Radius.circular(10),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: fileRef.value == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(IconPath.gararelly, width: 24, height: 24),
                        SizedBox(height: 6),
                        Text(
                          title,
                          style: getTextStyle(
                            color: Colors.blueAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "(Max. File Size: 5 MB)",
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
                          fileRef.value!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 120,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => ctrl.removeImage(fileRef),
                          child: Container(
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
