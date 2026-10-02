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
    this.existingUrl,
  });

  final IdentityCardController ctrl;
  final String title;
  final Rx<File?> fileRef;
  final RxString? existingUrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasFile = fileRef.value != null;
      final hasNetwork = existingUrl != null && existingUrl!.value.isNotEmpty;

      return GestureDetector(
        onTap: (!hasFile && !hasNetwork) ? () => ctrl.pickImage(fileRef) : null,
        child: DottedBorder(
          color: Colors.grey.shade400,
          strokeWidth: 1.2,
          dashPattern: const [6, 4],
          borderType: BorderType.RRect,
          radius: const Radius.circular(10),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: hasFile
                ? Stack(
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
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : hasNetwork
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              existingUrl!.value,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 120,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () {
                                existingUrl!.value = '';
                                ctrl.pickImage(fileRef);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Uploaded (Tap pen to replace)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(IconPath.gararelly, width: 24, height: 24),
                            const SizedBox(height: 6),
                            Text(
                              title,
                              style: getTextStyle(
                                color: Colors.blueAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
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
                      ),
          ),
        ),
      );
    });
  }
}
