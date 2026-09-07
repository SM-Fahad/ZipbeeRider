import 'dart:io';

import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
// import 'package:ZipBee_Driver/core/utils/constants/image_path.dart';
import 'package:ZipBee_Driver/features/auth/driver_documents/controller/driver_documents_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widget/driver_photo.dart';
import '../widget/driver_id_front.dart';
import '../widget/driver_id_back.dart';

class DriverDocumentsScreen extends StatelessWidget {
  DriverDocumentsScreen({super.key});

  final DriverDocumentsController controller = Get.put(
    DriverDocumentsController(),
  );

  // =================== Format Date ===================
  String _formatDate(String dateString) {
    if (dateString.isEmpty) return "Not provided";
    try {
      final date = DateTime.parse(dateString);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  // =================== Info Row ===================
  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  // =================== Section Button ===================
  Widget _sectionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _vehicleTile({
    required String title,
    required String icon,
    required Rx<File?> file,
    required RxString imageUrl,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Image.asset(icon, width: 24, height: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Obx(() {
                    if (file.value != null) {
                      return Text(
                        file.value!.path.split('/').last,
                        style: getTextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    } else if (imageUrl.value.isNotEmpty) {
                      return Text(
                        imageUrl.value.split('/').last,
                        style: getTextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      );
                    } else {
                      return Text(
                        title,
                        style: getTextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      );
                    }
                  }),
                ),
                const Icon(Icons.upload_file, size: 20),
              ],
            ),
          ),
        ),
        // Expanded image preview
        Obx(() {
          if (file.value != null || imageUrl.value.isNotEmpty) {
            return Container(
              height: 150,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: file.value != null
                  ? Image.file(file.value!, fit: BoxFit.cover)
                  : Image.network(
                      imageUrl.value.startsWith('http')
                          ? imageUrl.value
                          : '${ApiEndPoint.baseUrl}/${imageUrl.value}',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Icon(Icons.broken_image)),
                    ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: Get.back,
        ),
        title: const Text(
          "Driver Documents",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= DRIVER PROFILE PHOTO SECTION =================
            _sectionButton(
              title: "Driver Profile Photo",
              subtitle: "Upload and manage your driver photo",
              icon: Icons.person,
              onTap: () => Get.to(const DriverPhotoScreen()),
            ),

            SizedBox(height: 12),

            // ================= NRIC INFO DISPLAY =================
            Center(
              child: Text(
                "NRIC Information",
                style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(
                      "NRIC Number",
                      controller.nricNumber.value.isEmpty
                          ? "Not provided"
                          : controller.nricNumber.value,
                    ),
                    const SizedBox(height: 12),
                    _infoRow(
                      "Issue Date",
                      controller.nricIssueDate.value.isEmpty
                          ? "Not provided"
                          : _formatDate(controller.nricIssueDate.value),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 30),

            // ================= NRIC SECTION =================
            _sectionButton(
              title: "NRIC Information",
              subtitle: "Front of your ID card",
              icon: Icons.credit_card,
              onTap: () => Get.to(const IdentityFrontScreen()),
            ),
            SizedBox(height: 12),
            _sectionButton(
              title: "NRIC Information",
              subtitle: "Back of your ID card",
              icon: Icons.credit_card,
              onTap: () => Get.to(const IdentityBackScreen()),
            ),
            SizedBox(height: 12),

            // ================= DRIVING LICENSE SECTION =================
            Center(
              child: Text(
                "Driving License Information",
                style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(
                      "License Number",
                      controller.drivingLicenseNumber.value.isEmpty
                          ? "Not provided"
                          : controller.drivingLicenseNumber.value,
                    ),
                    const SizedBox(height: 12),
                    _infoRow(
                      "Issue Date",
                      controller.drivingLicenseIssueDate.value.isEmpty
                          ? "Not provided"
                          : _formatDate(
                              controller.drivingLicenseIssueDate.value,
                            ),
                    ),
                    const SizedBox(height: 12),
                    _infoRow(
                      "License Class",
                      controller.licenseClass.value.isEmpty
                          ? "Not provided"
                          : controller.licenseClass.value,
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 30),

            // const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
