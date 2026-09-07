import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/api_end_point/api_end_point.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/utils/constants/appcolors.dart';
import '../controller/driver_documents_controller.dart';

class IdentityFrontScreen extends StatelessWidget {
  const IdentityFrontScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverDocumentsController>();

    return Scaffold(
      appBar: AppBar(title: const Text("NRIC (Front)")),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryButtonColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () => controller.updateDocumentData(),
          child: Text("Submit", style: getTextStyle(color: Colors.white)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// NRIC INFO
            // Container(
            //   padding: const EdgeInsets.all(12),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(8),
            //     border: Border.all(color: Colors.grey.shade300),
            //     color: Colors.grey.shade50,
            //   ),
            //   child: Obx(() {
            //     return Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         _infoRow(
            //           "NRIC Number",
            //           controller.nricNumber.value.isEmpty
            //               ? "Not provided"
            //               : controller.nricNumber.value,
            //         ),
            //         const SizedBox(height: 8),
            //         _infoRow(
            //           "Issue Date",
            //           controller.nricIssueDate.value.isEmpty
            //               ? "Not provided"
            //               : _formatDate(controller.nricIssueDate.value),
            //         ),
            //       ],
            //     );
            //   }),
            // ),

            // const SizedBox(height: 20),

            /// ID CARD SIZE (16:10)
            Obx(() {
              Widget image;

              if (controller.idFront.value != null) {
                image = Image.file(
                  controller.idFront.value!,
                  fit: BoxFit.cover,
                );
              } else if (controller.idFrontUrl.isNotEmpty) {
                image = Image.network(
                  controller.idFrontUrl.value.startsWith('http')
                      ? controller.idFrontUrl.value
                      : '${ApiEndPoint.baseUrl}/${controller.idFrontUrl.value}',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Icon(Icons.broken_image)),
                );
              } else {
                image = const Center(child: Icon(Icons.credit_card, size: 60));
              }

              return AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: image,
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
            const Text("Make sure the ID card is clearly visible"),

            const SizedBox(height: 24),

            _button(
              Icons.image,
              "Upload photo",
              () => controller.pickImage(controller.idFront),
            ),
          ],
        ),
      ),
    );
  }

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
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _button(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 16),
            Text(text, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
