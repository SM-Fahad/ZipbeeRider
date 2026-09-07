import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/incentives/controller/incentives_controller.dart';
import 'package:ZipBee_Driver/features/incentives/widgets/incentive_stats_section.dart';
import 'package:ZipBee_Driver/features/incentives/widgets/incentive_tier_header.dart';
import 'package:ZipBee_Driver/features/incentives/widgets/incentives_list_section.dart';
import 'package:ZipBee_Driver/features/incentives/widgets/main_incentive_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IncentiveScreen extends StatelessWidget {
  IncentiveScreen({super.key});

  final IncentivesController controller =
      Get.isRegistered<IncentivesController>()
      ? Get.find<IncentivesController>()
      : Get.put(IncentivesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.onboardingIndicatorActive,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Incentive',
            style: getTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Obx(
              () => IncentiveTierHeader(
                currentTier: controller.currentTier.value,
              ),
            ),
            const SizedBox(height: 25),
            MainIncentiveCard(controller: controller),
            const SizedBox(height: 30),
            Obx(
              () => IncentiveStatsSection(
                stats: controller.stats.value,
                isLoading: controller.statsLoading.value,
              ),
            ),
            const SizedBox(height: 30),
            IncentivesListSection(controller: controller),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
