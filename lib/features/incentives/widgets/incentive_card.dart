import 'package:ZipBee_Driver/features/incentives/controller/incentives_controller.dart';
import 'package:ZipBee_Driver/features/incentives/model/incentive_model.dart';
import 'package:ZipBee_Driver/features/incentives/widgets/incentive_collect_action.dart';
import 'package:ZipBee_Driver/features/incentives/widgets/incentive_date_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IncentiveCard extends StatelessWidget {
  const IncentiveCard({
    super.key,
    required this.incentive,
    required this.controller,
  });

  final IncentiveModel incentive;
  final IncentivesController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  incentive.incentiveName.isEmpty
                      ? 'Untitled incentive'
                      : incentive.incentiveName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  incentive.status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Type: ${incentive.type}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                'Bonus: \$${incentive.incentiveAmount}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          incentiveDateLabel(
            startDate: incentive.startDate,
            endDate: incentive.endDate,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(() {
                final isCollected = controller.isIncentiveCollected(
                  incentive.id,
                  status: incentive.status,
                );
                final isCollecting = controller.isCollectingIncentive(
                  incentive.id,
                );

                return IncentiveCollectAction(
                  compact: true,
                  isCollected: isCollected,
                  isCollecting: isCollecting,
                  isAutoClaim: incentive.isAutoClaim,
                  isActive: incentive.isActive,
                  onCollect: () {
                    controller.collectBonus(incentiveId: incentive.id);
                  },
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
