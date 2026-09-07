import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/features/incentives/model/incentive_stats_model.dart';
import 'package:flutter/material.dart';

class IncentiveStatsSection extends StatelessWidget {
  const IncentiveStatsSection({
    super.key,
    required this.stats,
    required this.isLoading,
  });

  final IncentiveStatsModel? stats;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: SizedBox(height: 100, child: CircularProgressIndicator()),
      );
    }

    final statsData = stats;
    if (statsData == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Colors.yellow[700]!.withValues(alpha: 0.1),
            Colors.orange[700]!.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(color: Colors.yellow[700]!, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Incentive Stats',
            style: getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatCard(
                label: 'Total Active',
                value: statsData.countAll.toString(),
                icon: Icons.trending_up,
              ),
              _StatCard(
                label: 'Active Riders',
                value: statsData.countActiveRider.toString(),
                icon: Icons.people,
              ),
              _StatCard(
                label: 'Ongoing',
                value: statsData.countOngoing.toString(),
                icon: Icons.timer,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount Given:',
                  style: getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${statsData.totalAmountGiven.toStringAsFixed(2)}',
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.yellow[700]!.withValues(alpha: 0.2),
          ),
          child: Icon(icon, color: Colors.yellow[700], size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
