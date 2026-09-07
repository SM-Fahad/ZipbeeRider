import 'package:ZipBee_Driver/features/incentives/controller/incentives_controller.dart';
import 'package:ZipBee_Driver/features/incentives/model/incentive_model.dart';
import 'package:ZipBee_Driver/features/incentives/widgets/incentive_collect_action.dart';
import 'package:ZipBee_Driver/features/incentives/widgets/incentive_date_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainIncentiveCard extends StatelessWidget {
  const MainIncentiveCard({super.key, required this.controller});

  final IncentivesController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final featuredIncentive = controller.incentives.firstWhereOrNull(
        (incentive) => incentive.isActive,
      );

      if (featuredIncentive == null) {
        return const _DefaultIncentiveCard();
      }

      return _FeaturedIncentiveCard(
        incentive: featuredIncentive,
        controller: controller,
      );
    });
  }
}

class _FeaturedIncentiveCard extends StatelessWidget {
  const _FeaturedIncentiveCard({
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
        border: Border.all(color: Colors.yellow[700]!, width: 2),
        color: Colors.yellow[50],
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
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.yellow[700],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'FEATURED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type: ${incentive.type}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bonus Amount: \$${incentive.incentiveAmount}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Flexible(
                child: incentiveDateLabel(
                  startDate: incentive.startDate,
                  endDate: incentive.endDate,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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

class _DefaultIncentiveCard extends StatelessWidget {
  const _DefaultIncentiveCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey[50],
      ),
      child: const Center(
        child: Text(
          'No active incentives at the moment',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
