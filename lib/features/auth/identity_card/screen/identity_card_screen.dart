import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/auth/identity_card/widgets/dates_row_widget.dart';
import 'package:ZipBee_Driver/features/auth/identity_card/widgets/reusable_upload_box_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/identity_card_controller.dart';

class IdentityCardScreen extends StatelessWidget {
  final IdentityCardController ctrl = Get.put(IdentityCardController());

  IdentityCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.black, width: 1.0),
    );

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
      body: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.black,
            selectionColor: Colors.black26,
            selectionHandleColor: Colors.black,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// --- Step Indicator ---
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
                        color: (index == 0 || index == 1)
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
                  "Identity Card",
                  style: getTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 30),

              Text(
                "NRIC Number*",
                style: getTextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 6),
              TextField(
                controller: ctrl.nidController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: "Enter NRIC Number",
                  hintStyle: getTextStyle(color: Colors.grey.shade500),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder,
                ),
              ),
              SizedBox(height: 30),

              Text(
                "Issue Date*",
                style: getTextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 6),
              Obx(
                () => TextField(
                  readOnly: true,
                  onTap: () => ctrl.pickDate(context, ctrl.identityIssueDate),
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: ctrl.identityIssueDate.value.isEmpty
                        ? "DD/MM/YYYY"
                        : ctrl.identityIssueDate.value,
                    hintStyle: getTextStyle(
                      color: ctrl.identityIssueDate.value.isEmpty
                          ? Colors.grey.shade500
                          : Colors.black,
                    ),
                    border: inputBorder,
                    enabledBorder: inputBorder,
                    focusedBorder: inputBorder,
                    suffixIcon: Icon(Icons.calendar_today, size: 20),
                  ),
                ),
              ),
              SizedBox(height: 30),

              Text(
                "NRIC Front*",
                style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              ReusableUploadBox(
                ctrl: ctrl,
                title: "Click to upload",
                fileRef: ctrl.frontIdCard,
              ),
              SizedBox(height: 30),

              Text(
                "NRIC Back*",
                style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              ReusableUploadBox(
                ctrl: ctrl,
                title: "Click to upload",
                fileRef: ctrl.backIdCard,
              ),
              SizedBox(height: 40),

              Text(
                "Driving License Number*",
                style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              TextField(
                controller: ctrl.licenseController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: "Enter Driving License Number",
                  hintStyle: getTextStyle(color: Colors.grey.shade500),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder,
                ),
              ),

              SizedBox(height: 30),

              DatesRow(ctrl: ctrl, inputBorder: inputBorder),

              SizedBox(height: 30),

              Text("Driving License Front*"),
              SizedBox(height: 8),
              // ReusableUploadBox------
              ReusableUploadBox(
                ctrl: ctrl,
                title: "Click to upload",
                fileRef: ctrl.frontLicenseCard,
              ),
              SizedBox(height: 30),

              Text("Driving License Back*"),
              SizedBox(height: 8),
              ReusableUploadBox(
                ctrl: ctrl,
                title: "Click to upload",
                fileRef: ctrl.backLicenseCard,
              ),
              SizedBox(height: 40),

              /// --- Continue Button ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
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
      ),
    );
  }
}
