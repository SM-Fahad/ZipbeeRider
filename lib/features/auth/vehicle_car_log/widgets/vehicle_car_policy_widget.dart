import 'package:ZipBee_Driver/features/auth/vehicle_car_log/controller/vehicle_car_log_controller.dart';
import 'package:ZipBee_Driver/features/auth/vehicle_car_log/screen/vehicle_car_log_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';


class VehicleCarPolicy extends StatelessWidget {
  const VehicleCarPolicy({super.key, required this.ctrl});

  final VehicleCarLogController ctrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// ISSUE DATE
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Issue Date*",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 6),
              Obx(() {
                final formattedDate = ctrl.formatDate(ctrl.policyIssueDate.value);
                return TextField(
                  readOnly: true,
                  onTap: () => ctrl.pickDate(isIssue: true, isPolicy: true),
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: formattedDate.isEmpty
                        ? "DD/MM/YYYY"
                        : formattedDate,
                    hintStyle: TextStyle(
                      color: formattedDate.isEmpty ? Colors.grey.shade500 : Colors.black,
                    ),
                    border: inputBorder,
                    enabledBorder: inputBorder,
                    focusedBorder: inputBorder,
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.grey[500],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        SizedBox(width: 40),

        /// EXPIRY DATE
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Expiry Date*",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 6),
              Obx(() {
                final formattedDate = ctrl.formatDate(ctrl.policyExpiryDate.value);
                return TextField(
                  readOnly: true,
                  onTap: () => ctrl.pickDate(isIssue: false, isPolicy: true),
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: formattedDate.isEmpty
                        ? "DD/MM/YYYY"
                        : formattedDate,
                    hintStyle: TextStyle(
                      color: formattedDate.isEmpty ? Colors.grey.shade500 : Colors.black,
                    ),
                    border: inputBorder,
                    enabledBorder: inputBorder,
                    focusedBorder: inputBorder,
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.grey[500],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
