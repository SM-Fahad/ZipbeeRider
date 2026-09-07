import 'package:ZipBee_Driver/core/utils/constants/image_path.dart';
import 'package:ZipBee_Driver/features/statistics/controller/statistics_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StatisticsScreen extends StatelessWidget {
  StatisticsScreen({super.key});

  final controller = Get.put(StatisticsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: Get.back,
        ),
        title: const Text(
          "Statistics",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.chartItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRangeSelector(),
              const SizedBox(height: 18),
              _buildChartCard(),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Earning & Rides",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Obx(
                () => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      controller.formatAmount(controller.totalEarning.value),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Obx(
                () => Row(
                  children: [
                    _buildStatCard(
                      "Total Trips",
                      "${controller.totalTips.value.toStringAsFixed(0)}",
                    ),
                    const SizedBox(width: 15),
                    _buildStatCard(
                      "Total driving Hrs",
                      "${controller.totalDrivingHours.value.toStringAsFixed(1)} Hrs",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Badges",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(
                  () => Row(
                    children: [
                      _buildBadgeCard(
                        "Bronze",
                        ImagePath.bronze,
                        const Color(0xFFCD7F32),
                        active: controller.currentBadge.value == 'BRONZE',
                      ),
                      _buildBadgeCard(
                        "Silver",
                        ImagePath.silver,
                        Colors.grey,
                        active: controller.currentBadge.value == 'SILVER',
                      ),
                      _buildBadgeCard(
                        "Gold",
                        ImagePath.gold,
                        const Color(0xFFFFD700),
                        active: controller.currentBadge.value == 'GOLD',
                      ),
                      _buildBadgeCard(
                        "Platinum",
                        ImagePath.diamond,
                        const Color(0xFF95E1D3),
                        active: controller.currentBadge.value == 'PLATINUM',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRangeSelector() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildRangeTab(
              title: 'Daily',
              range: StatisticsRangeType.daily,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildRangeTab(
              title: 'Weekly',
              range: StatisticsRangeType.weekly,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildRangeTab(
              title: 'Monthly',
              range: StatisticsRangeType.monthly,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeTab({
    required String title,
    required StatisticsRangeType range,
  }) {
    final isSelected = controller.selectedRange.value == range;
    return GestureDetector(
      onTap: () => controller.changeRange(range),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.black : const Color(0xFFE5E7EB),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Text(
              controller.rangeTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 280,
            child: Obx(() {
              final items = controller.chartItems;
              if (items.isEmpty) {
                return const Center(child: Text('No data available'));
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: (items.length * 72).toDouble().clamp(420, 1200),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: controller.maxChartValue,
                      barTouchData: BarTouchData(enabled: false),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: controller.maxChartValue / 4,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Colors.grey.withValues(alpha: 0.12),
                          strokeWidth: 1,
                        ),
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= items.length) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  items[index].label,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: item.value <= 0 ? 0.1 : item.value,
                              width: 28,
                              borderRadius: BorderRadius.circular(8),
                              color: index == items.length - 1
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFF1F2937),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: controller.maxChartValue,
                                color: Colors.grey.withValues(alpha: 0.12),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(
    String title,
    String imagePath,
    Color borderColor, {
    bool active = false,
  }) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 60,
            width: 60,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  imagePath,
                  height: 60,
                  width: 60,
                  fit: BoxFit.contain,
                ),
                if (active)
                  const Positioned(
                    top: -4,
                    right: -4,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.check, color: Colors.white, size: 14),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
