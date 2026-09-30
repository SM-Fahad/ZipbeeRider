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
      final hasFile = ctrl.driverPhoto.value != null;
      final hasNetwork = ctrl.existingDriverPhotoUrl.value.isNotEmpty;

      return GestureDetector(
        onTap: (!hasFile && !hasNetwork) ? ctrl.pickDriverPhoto : null,
        child: DottedBorder(
          color: Colors.grey.shade400,
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
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
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
                              ctrl.existingDriverPhotoUrl.value,
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: GestureDetector(
                              onTap: () {
                                ctrl.existingDriverPhotoUrl.value = '';
                                ctrl.pickDriverPhoto();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.white,
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
                                'Current Photo (Tap pen to replace)',
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
                              "Upload a clear photo of yourself",
                              style: getTextStyle(
                                color: Colors.blueAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
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
                      ),
          ),
        ),
      );
    });
  }
}
