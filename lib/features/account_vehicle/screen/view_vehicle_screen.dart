import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/account_vehicle/controller/controller.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewVehicleScreen extends StatelessWidget {
  ViewVehicleScreen({super.key});

  final VehicleController controller = Get.put(VehicleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Vehicle Details"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.offNamed(AppRoutes.bottomNavbarScreen),
        ),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    /// ========== VEHICLE DETAILS SECTION ==========
                    _buildSection(
                      title: "Vehicle Details",
                      icon: Icons.directions_car,
                      children: [
                        _buildDetailRow(
                          "Plate Number",
                          controller.vehiclePlateCtrl.text,
                        ),
                        Obx(
                          () => _buildDetailRow(
                            "Type",
                            controller.vehicleTypeName.value,
                          ),
                        ),
                        _buildDetailRow(
                          "Brand",
                          controller.vehicleBrandCtrl.text,
                        ),
                        _buildDetailRow(
                          "Model",
                          controller.vehicleModelCtrl.text,
                        ),
                        _buildDetailRow(
                          "Registration Date",
                          controller.registrationDate.value != null
                              ? controller.registrationDate.value!
                                    .toIso8601String()
                                    .split('T')
                                    .first
                              : '-',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// ========== VEHICLE IMAGES SECTION ==========
                    _buildSection(
                      title: "Vehicle Images",
                      icon: Icons.image,
                      isGrid: true,
                      children: [
                        _buildImageTile(
                          "Front View",
                          controller.vehicleFrontUrl,
                        ),
                        _buildImageTile("Rear View", controller.vehicleBackUrl),
                        _buildImageTile(
                          "Driver Side",
                          controller.vehicleDriverSideUrl,
                        ),
                        _buildImageTile(
                          "Passenger Side",
                          controller.vehiclePassengerSideUrl,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// ========== VEHICLE LOG CARD SECTION ==========
                    _buildSection(
                      title: "Vehicle Log Card",
                      icon: Icons.description,
                      children: [
                        _buildDetailRow(
                          "Chassis Number",
                          controller.chassisNumberCtrl.text,
                        ),
                        _buildImageTile(
                          "Log Card Document",
                          controller.vehicleLogImageUrl,
                          isDocument: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// ========== INSURANCE POLICY SECTION ==========
                    _buildSection(
                      title: "Insurance Policy",
                      icon: Icons.shield_outlined,
                      children: [
                        _buildDetailRow(
                          "Policy Number",
                          controller.vehiclePolicyCtrl.text,
                        ),
                        _buildDetailRow(
                          "Issue Date",
                          controller.policyIssueDate.value != null
                              ? controller.policyIssueDate.value!
                                    .toIso8601String()
                                    .split('T')
                                    .first
                              : '-',
                        ),
                        _buildDetailRow(
                          "Expire Date",
                          controller.policyExpireDate.value != null
                              ? controller.policyExpireDate.value!
                                    .toIso8601String()
                                    .split('T')
                                    .first
                              : '-',
                        ),
                        _buildImageTile(
                          "Policy Document",
                          controller.policyImageUrl,
                          isDocument: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// ========== EDIT BUTTON ==========
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Get.toNamed('/updateVehicleScreen'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryButtonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Edit Vehicle Details",
                            style: getTextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool isGrid = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryButtonColor.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primaryButtonColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: isGrid
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: children.length,
                      itemBuilder: (context, index) => children[index],
                    )
                  : Column(
                      children: [
                        for (int i = 0; i < children.length; i++) ...[
                          children[i],
                          if (i < children.length - 1)
                            const SizedBox(height: 12),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: getTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value.isEmpty ? '-' : value,
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile(
    String label,
    RxString imageUrl, {
    bool isDocument = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        Obx(
          () => GestureDetector(
            onTap: () {
              if (imageUrl.value.isNotEmpty) {
                Get.dialog(
                  Dialog(
                    backgroundColor: Colors.transparent,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Image.network(
                        imageUrl.value.startsWith('http')
                            ? imageUrl.value
                            : '${ApiEndPoint.baseUrl}/${imageUrl.value}',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: imageUrl.value.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isDocument ? Icons.description : Icons.image,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isDocument ? 'No document' : 'No image',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl.value.startsWith('http')
                            ? imageUrl.value
                            : '${ApiEndPoint.baseUrl}/${imageUrl.value}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
