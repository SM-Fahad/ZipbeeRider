// ignore_for_file: deprecated_member_use

import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/auth/login/widgets/phone_field_widget.dart';
import 'package:ZipBee_Driver/features/auth/rider_details/controller/rider_details_controller.dart';
import 'package:ZipBee_Driver/features/auth/rider_details/widgets/driver_photo_widget.dart';
import 'package:ZipBee_Driver/features/auth/rider_details/widgets/step_box_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RiderDetailsScreen extends StatelessWidget {
  final RiderDetailsController ctrl = Get.put(RiderDetailsController());

  RiderDetailsScreen({super.key});

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
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepBox(),
            SizedBox(height: 26),

            Center(
              child: Text(
                "Driver’s Details",
                style: getTextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 26),

            buildTextField("Name*", "Enter name", ctrl.driverNameController),
            SizedBox(height: 30),

            buildTextField(
              "Mobile Number*",
              "Enter number",
              ctrl.contactNumberController,
              phoneCode: ctrl.selectedCountryCode,
            ),
            SizedBox(height: 30),

            buildTextField(
              "Email Address*",
              "Enter email",
              ctrl.emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 30),

            /// DOB
            Text("Date of Birth*", style: labelStyle()),
            SizedBox(height: 6),

            TextField(
              controller: ctrl.dobController,
              readOnly: true,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (picked != null) {
                  ctrl.dobController.text =
                      "${picked.day}/${picked.month}/${picked.year}";
                }
              },
              decoration: inputDecoration(
                "Select birth of date",
                suffixIcon: Icons.calendar_today,
              ),
            ),
            SizedBox(height: 30),

            /// Gender
            Text("Select Gender*", style: labelStyle()),
            SizedBox(height: 6),

            Row(
              children: [
                genderOption("Male"),
                SizedBox(width: 10),
                genderOption("Female"),
                SizedBox(width: 10),
                genderOption("Other"),
              ],
            ),
            SizedBox(height: 30),

            Text("Profile Photo*", style: labelStyle()),
            SizedBox(height: 10),

            DriverPhoto(ctrl: ctrl),
            SizedBox(height: 20),

            buildTextField(
              "Emergency Contact Name*",
              "Enter name",
              ctrl.emergencyContactNameController,
            ),
            SizedBox(height: 30),

            buildTextField(
              "Emergency Mobile Number*",
              "Enter number",
              ctrl.emergencyContactNumberController,
              phoneCode: ctrl.emergencySelectedCountryCode,
            ),
            SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => ctrl.submitRiderDetails(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.onboardingIndicatorActive,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Continue",
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
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

  TextStyle labelStyle() =>
      TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black);

  Widget genderOption(String gender) {
    final RiderDetailsController ctrl = Get.find();

    return Obx(
      () => Row(
        children: [
          Radio<String>(
            value: gender,
            groupValue: ctrl.selectedGender.value,
            activeColor: AppColors.onboardingIndicatorActive,
            onChanged: (value) => ctrl.selectedGender.value = value!,
          ),
          Text(gender),
        ],
      ),
    );
  }

  Widget buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    RxString? phoneCode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 6),
        phoneCode != null
            ? PhoneInputField(
                textController: controller,
                selectedCountryCode: phoneCode,
                hintText: hint,
              )
            : TextField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: inputDecoration(hint),
              ),
      ],
    );
  }

  InputDecoration inputDecoration(String hint, {IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey),
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: Colors.grey)
          : null,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.black, width: 1),
      ),
    );
  }
}
