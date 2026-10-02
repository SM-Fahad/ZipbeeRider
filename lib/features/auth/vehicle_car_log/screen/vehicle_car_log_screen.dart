import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
import 'package:ZipBee_Driver/features/auth/vehicle_car_log/controller/vehicle_car_log_controller.dart';
import 'package:ZipBee_Driver/features/auth/vehicle_car_log/widgets/vehicle_car_policy_widget.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ---------------- GLOBAL INPUT BORDER ----------------
final OutlineInputBorder inputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(8),
  borderSide: BorderSide(color: Colors.grey, width: 1),
);

class VehicleCarLogScreen extends StatelessWidget {
  VehicleCarLogScreen({super.key});

  final VehicleCarLogController ctrl = Get.put(VehicleCarLogController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Registration',
          style: getTextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: Get.back,
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------------- STEP INDICATOR ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: index == 0 ? 0 : 4,
                    ),
                    height: 6,
                    decoration: BoxDecoration(
                      color: index <= 3
                          ? AppColors.onboardingIndicatorActive
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: 26),

            Center(
              child: Text(
                "Vehicle Log Card",
                style: getTextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),

            SizedBox(height: 30),

            /// ---------------- CHASSIS NUMBER ----------------
            label('Chassis Number*'),
            TextField(
              controller: ctrl.chassisNumberController,
              decoration: InputDecoration(
                hintText: 'Enter Chassis Number',
                border: inputBorder,
                enabledBorder: inputBorder,
                focusedBorder: inputBorder.copyWith(
                  borderSide: BorderSide(color: Colors.black, width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),

            SizedBox(height: 30),

            /// ---------------- VEHICLE DOCUMENT ----------------
            label('Vehicle Log Card*'),
            Obx(() {
              return filePickerBox(
                file: ctrl.vehicleLogFile.value,
                existingUrl: ctrl.existingVehicleLogUrl.value,
                onTap: ctrl.pickVehicleLogFile,
              );
            }),

            SizedBox(height: 30),

            Center(
              child: Text(
                "Vehicle Insurance Policy",
                style: getTextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),

            SizedBox(height: 26),

            /// ---------------- VEHICLE CAR LOG NUMBER ----------------
            label('Insurance Policy Number*'),
            TextField(
              controller: ctrl.policyNumberController,
              decoration: InputDecoration(
                hintText: 'Enter Insurance Policy number',
                border: inputBorder,
                enabledBorder: inputBorder,
                focusedBorder: inputBorder.copyWith(
                  borderSide: BorderSide(color: Colors.black, width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),

            SizedBox(height: 30),

            /// ---------------- Vehicle Car Policy ISSUE/EXPIRY DATE ROW ----------------
            VehicleCarPolicy(ctrl: ctrl),

            /// ---------------- INSURANCE DOCUMENT ----------------
            label('Insurance Policy Document*'),
            Obx(() {
              return filePickerBox(
                file: ctrl.vehiclePolicyFile.value,
                existingUrl: ctrl.existingVehiclePolicyUrl.value,
                onTap: ctrl.pickPolicyFile,
              );
            }),

            SizedBox(height: 40),

            /// ---------------- CONTINUE BUTTON ----------------
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ctrl.submitVehicleDetails();
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  /// ---------------- LABEL ----------------
  Widget label(String text) => Padding(
    padding: EdgeInsets.only(bottom: 9.0, top: 18),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  /// ---------------- FILE PICKER BOX ----------------
  Widget filePickerBox({
    required VoidCallback onTap,
    PlatformFile? file,
    String? existingUrl,
  }) {
    if (file != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.insert_drive_file, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(file.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    '${(file.size / 1024).toStringAsFixed(1)} KB',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onTap,
              child: const Icon(Icons.edit, color: Colors.blue),
            ),
          ],
        ),
      );
    }

    if (existingUrl != null && existingUrl.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FDF9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF81C784), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Document Already Uploaded',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tap edit to replace with new document',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onTap,
              child: const Icon(Icons.edit, color: Colors.blue),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(8),
        dashPattern: const [6, 4],
        color: Colors.grey.shade400,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(IconPath.gararelly, height: 24, width: 24),
              const SizedBox(height: 8),
              const SizedBox(height: 6),
              const Text(
                '(Max. File size: 25 MB)',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
