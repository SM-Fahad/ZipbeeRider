import 'dart:io';

import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/account_vehicle/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common/style/global_text_style.dart';

class UpdateVehicleScreen extends StatelessWidget {
  UpdateVehicleScreen({super.key});

  final VehicleController controller = Get.put(VehicleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Update Vehicle Details"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= VEHICLE DETAILS =================
            section("Vehicle Details"),

            section("Vehicle Plate Number*"),
            textField(controller.vehiclePlateCtrl),

            section("Vehicle Type*"),
            Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  value: controller.vehicleTypeCtrl.text.isEmpty
                      ? null
                      : controller.vehicleTypeCtrl.text,
                  items: controller.vehicleTypes
                      .map(
                        (vehicleType) => DropdownMenuItem(
                          value: vehicleType.id.toString(),
                          child: Text(vehicleType.vehicleName),
                        ),
                      )
                      .toList(),
                  onChanged: controller.isVehicleTypesLoading.value
                      ? null
                      : (val) {
                          controller.vehicleTypeCtrl.text = val ?? '';
                          controller.vehicleTypeName.value = controller
                              .getVehicleTypeName(
                                int.tryParse(val ?? '0') ?? 0,
                              );
                        },
                  hint: Text(
                    controller.isVehicleTypesLoading.value
                        ? 'Loading vehicle types...'
                        : 'Select vehicle type',
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            section("Vehicle Brand*"),
            textField(controller.vehicleBrandCtrl),
            section("Vehicle Model*"),
            textField(controller.vehicleModelCtrl),

            section("Registration Date*"),
            dateField(controller.registrationDate),

            section("Front View of Vehicle*"),
            imageField(
              file: controller.vehicleFront,
              imageUrl: controller.vehicleFrontUrl,
            ),

            section("Rear View of Vehicle*"),
            imageField(
              file: controller.vehicleBack,
              imageUrl: controller.vehicleBackUrl,
            ),

            section("Driver Side View*"),
            imageField(
              file: controller.vehicleDriverSide,
              imageUrl: controller.vehicleDriverSideUrl,
            ),

            section("Passenger Side View*"),
            imageField(
              file: controller.vehiclePassengerSide,
              imageUrl: controller.vehiclePassengerSideUrl,
            ),

            // ================= VEHICLE LOG CARD =================
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Vehicle Log Card",
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            section("Chassis Number*"),
            textField(controller.chassisNumberCtrl),

            section("Vehicle Log Card Document*"),
            imageField(
              file: controller.vehicleLogImage,
              imageUrl: controller.vehicleLogImageUrl,
            ),

            // ================= VEHICLE INSURANCE POLICY =================
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Vehicle Insurance Policy",
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            section("Insurance Policy Number*"),
            textField(controller.vehiclePolicyCtrl),

            section("Issue Date*"),
            dateField(controller.policyIssueDate),

            section("Expire Date*"),
            dateField(controller.policyExpireDate),

            section("Insurance Policy Document*"),
            imageField(
              file: controller.policyImage,
              imageUrl: controller.policyImageUrl,
            ),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.updateVehicleData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Update Vehicle",
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
    );
  }

  // ================= REUSABLE WIDGETS =================
  Widget section(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
  );

  Widget textField(TextEditingController ctrl) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: TextField(
      controller: ctrl,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    ),
  );

  Widget dateField(Rx<DateTime?> date) => Obx(
    () => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => controller.pickDate(date),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date.value == null
                    ? "Select Date"
                    : date.value!.toIso8601String().split('T').first,
                style: TextStyle(
                  color: date.value == null ? Colors.grey : Colors.black,
                ),
              ),
              const Icon(Icons.calendar_today_outlined, color: Colors.grey),
            ],
          ),
        ),
      ),
    ),
  );

  Widget imageField({required Rx<File?> file, required RxString imageUrl}) =>
      Obx(
        () => GestureDetector(
          onTap: () => controller.pickImage(file),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade50,
              ),
              child: file.value != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(file.value!, fit: BoxFit.cover),
                    )
                  : imageUrl.value.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl.value.startsWith('http')
                            ? imageUrl.value
                            : '${ApiEndPoint.baseUrl}/${imageUrl.value}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Center(child: Icon(Icons.broken_image)),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to upload image',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
}
