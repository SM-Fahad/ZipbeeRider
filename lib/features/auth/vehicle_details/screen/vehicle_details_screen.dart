import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/auth/vehicle_details/controller/vehicle_details_controller.dart';
import 'package:ZipBee_Driver/features/auth/vehicle_details/widgets/labeled_upload_box_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VehicleDetailsScreen extends StatelessWidget {
  const VehicleDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(VehicleDetailsController());

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
            /// Step Indicator
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
                      color: (index == 0 || index == 1 || index == 2)
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
                "Vehicle Details",
                style: getTextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 30),

            /// Vehicle Plate Number
            Text(
              "Vehicle Plate Number*",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            TextField(
              controller: ctrl.plateNumberController,
              decoration: InputDecoration(
                hintText: 'Enter Plate Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 30),

            /// Dropdown
            Text(
              "Vehicle Type*",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: ctrl.selectedType.value.isEmpty
                    ? null
                    : ctrl.selectedType.value,
                items: ctrl.vehicleTypes
                    .map(
                      (vehicleType) => DropdownMenuItem(
                        value: vehicleType.id.toString(),
                        child: Text(vehicleType.vehicleName),
                      ),
                    )
                    .toList(),
                onChanged: ctrl.isVehicleTypesLoading.value
                    ? null
                    : (val) => ctrl.selectedType.value = val ?? '',
                hint: Text(
                  ctrl.isVehicleTypesLoading.value
                      ? 'Loading vehicle types...'
                      : 'Select vehicle type',
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),

            /// Brand
            Text(
              "Vehicle Brand*",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            TextField(
              controller: ctrl.brandController,
              decoration: InputDecoration(
                hintText: 'Enter Brand',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 30),

            /// Model
            Text(
              "Vehicle Model*",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            TextField(
              controller: ctrl.modelController,
              decoration: InputDecoration(
                hintText: 'Enter Model',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 30),

            /// Registration Date
            Text(
              "Registration Date*",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            TextField(
              controller: ctrl.registrationDateController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'DD/MM/YYYY',
                suffixIcon: Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              onTap: () => ctrl.selectDate(context),
            ),
            SizedBox(height: 40),

            /// Labeled Upload Boxes
            LabeledUploadBox(
              ctrl: ctrl,
              label: "Front View of Vehicle*",
              title: "Click to upload",
              fileRef: ctrl.frontImage,
            ),
            SizedBox(height: 40),
            LabeledUploadBox(
              ctrl: ctrl,
              label: "Rear View of Vehicle*",
              title: "Click to upload",
              fileRef: ctrl.backImage,
            ),
            SizedBox(height: 40),
            LabeledUploadBox(
              ctrl: ctrl,
              label: "Driver Side View*",
              title: "Click to upload",
              fileRef: ctrl.driverImage,
            ),
            SizedBox(height: 40),
            LabeledUploadBox(
              ctrl: ctrl,
              label: "Passenger Side View*",
              title: "Click to upload",
              fileRef: ctrl.passengerImage,
            ),

            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final ctrl = Get.find<VehicleDetailsController>();
                  ctrl.continueNext();
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Continue",
                  style: getTextStyle(
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
}
