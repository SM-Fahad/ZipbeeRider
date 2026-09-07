import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../controller/identity_card_controller.dart';

class DatesRow extends StatelessWidget {
  const DatesRow({super.key, required this.ctrl, required this.inputBorder});

  final IdentityCardController ctrl;
  final OutlineInputBorder inputBorder;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Issue Date*",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 6),
              Obx(
                () => TextField(
                  readOnly: true,
                  onTap: () =>
                      ctrl.pickDate(context, ctrl.drivingLicenseIssueDate),
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: ctrl.drivingLicenseIssueDate.value.isEmpty
                        ? "DD/MM/YYYY"
                        : ctrl.drivingLicenseIssueDate.value,
                    hintStyle: getTextStyle(color: Colors.black),
                    border: inputBorder,
                    enabledBorder: inputBorder,
                    focusedBorder: inputBorder,
                    suffixIcon: Icon(Icons.calendar_today, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "License Class*",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 6),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: ctrl.selectedLicenseClass.value.isEmpty
                      ? null
                      : ctrl.selectedLicenseClass.value,
                  decoration: InputDecoration(
                    hintText: "Select class",
                    hintStyle: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade500,
                    ),
                    border: inputBorder,
                    enabledBorder: inputBorder,
                    focusedBorder: inputBorder,
                  ),
                  items: ctrl.licenseClassOptions
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    ctrl.selectedLicenseClass.value = value ?? '';
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
