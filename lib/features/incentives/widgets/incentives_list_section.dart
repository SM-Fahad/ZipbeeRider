import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/features/incentives/controller/incentives_controller.dart';
import 'package:ZipBee_Driver/features/incentives/widgets/incentive_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IncentivesListSection extends StatelessWidget {
  const IncentivesListSection({super.key, required this.controller});

  final IncentivesController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.hasError.value || controller.incentives.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade50,
          ),
          child: Column(
            children: [
              Text(
                'No incentive created',
                style: getTextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (controller.hasError.value) ...[
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: getTextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchIncentives,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        );
      }

      return Column(
        children: controller.incentives.map((incentive) {
          final title = incentive.incentiveName.isEmpty
              ? 'Untitled incentive'
              : incentive.incentiveName;

          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              IncentiveCard(incentive: incentive, controller: controller),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      );
    });
  }
}
