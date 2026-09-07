import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/scan_and_pay/controller/scan_and_pay_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ScanAndPayScreen extends StatelessWidget {
  ScanAndPayScreen({super.key});

  final ScanAndPayController c = Get.put(ScanAndPayController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _amountBox(),
              const SizedBox(height: 18),
              // _durationBox(size),
              // const SizedBox(height: 28),
              _qrSection(size),
              const SizedBox(height: 32),
              _twoButtons(context, size),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: AppColors.onboardingIndicatorActive,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: Get.back,
      ),
      title: Text(
        'Scan & Pay',
        style: getTextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _amountBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Obx(
        () => Column(
          children: [
            Text(
              'Amount to be Collected',
              style: getTextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              '\$${c.codAmount.toStringAsFixed(2)}',
              style: getTextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _durationBox(Size size) {
  //   return Container(
  //     width: size.width * 0.9,
  //     padding: const EdgeInsets.all(18),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFEAF2FF),
  //       borderRadius: BorderRadius.circular(14),
  //     ),
  //     child: Obx(
  //       () => Column(
  //         children: [
  //           Text(
  //             'Estimated Duration',
  //             style: getTextStyle(
  //               color: Colors.blueAccent,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //           const SizedBox(height: 6),
  //           Text(
  //             c.durationText,
  //             style: getTextStyle(
  //               color: Colors.blueAccent,
  //               fontSize: 18,
  //               fontWeight: FontWeight.w700,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _qrSection(Size size) {
    return Obx(() {
      final isLoading = c.isLoadingQr.value;
      final qrData = c.qrData.value;
      final error = c.errorMessage.value;

      return Column(
        children: [
          Text(
            'QR Code',
            style: getTextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Customer can scan this code to complete payment.',
            textAlign: TextAlign.center,
            style: getTextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          Container(
            width: size.width * 0.76,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 44),
                    child: CircularProgressIndicator(),
                  )
                else if (qrData.isNotEmpty)
                  QrImageView(data: qrData, size: size.width * 0.55)
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Column(
                      children: [
                        Icon(
                          Icons.qr_code_2,
                          size: 82,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          error.isNotEmpty
                              ? error
                              : 'Unable to generate QR code.',
                          textAlign: TextAlign.center,
                          style: getTextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!isLoading && qrData.isEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: c.createCheckoutSession,
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _twoButtons(BuildContext context, Size size) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            label: 'Cost Details',
            icon: Icons.receipt_long_outlined,
            color: Colors.blue,
            onTap: () => _showCostDetailsBottomSheet(context),
          ),
        ),
        SizedBox(width: size.width * 0.04),
        Expanded(
          child: _actionButton(
            label: 'Done',
            icon: Icons.check_circle_outline,
            color: const Color(0xFF1FA34A),
            onTap: Get.back,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 0,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 6),
          Text(label, style: getTextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }

  void _showCostDetailsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: SafeArea(
          top: false,
          child: Obx(() {
            final summary = c.pricingSummary;
            final dropBreakdown = c.perDropBreakdown;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Cost Breakdown',
                    style: getTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _detailRow(
                    'Total Cost',
                    '\$${c.formatAmount(c.readPricingDouble('totalCost'))}',
                    emphasize: true,
                  ),
                  _detailRow(
                    'Total Distance',
                    '${c.formatAmount(c.readPricingDouble('totalDistance'))} km',
                  ),
                  _detailRow(
                    'Total Time',
                    '${c.readPricingInt('totalTimeMin')} mins',
                  ),
                  _detailRow(
                    'Base Price',
                    '\$${c.formatAmount(c.readPricingDouble('basePrice'))}',
                  ),
                  _detailRow(
                    'Delivery Type Charge',
                    '\$${c.formatAmount(c.readPricingDouble('deliveryTypeCharge'))}',
                  ),
                  _detailRow(
                    'Additional Service Fee',
                    '\$${c.formatAmount(c.readPricingDouble('additionServiceFee'))}',
                  ),
                  _detailRow(
                    'Total Fee',
                    '\$${c.formatAmount(c.readPricingDouble('totalFee'))}',
                  ),
                  _detailRow(
                    'Platform Fee',
                    '\$${c.formatAmount(c.readPricingDouble('totalPlatformFee'))}',
                  ),
                  _detailRow('Drop Count', '${c.readPricingInt('dropCount')}'),
                  _detailRow(
                    'Surge Applied',
                    c.readPricingBool('surgeApplied') ? 'Yes' : 'No',
                  ),
                  if (dropBreakdown.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      'Per Drop Breakdown',
                      style: getTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...dropBreakdown.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Drop ${index + 1}',
                              style: getTextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _detailRow(
                              'Price',
                              '\$${c.formatAmount(_numFrom(item['price']))}',
                              compact: true,
                            ),
                            _detailRow(
                              'Rider Earnings',
                              '\$${c.formatAmount(_numFrom(item['raiderEarnings']))}',
                              compact: true,
                            ),
                            _detailRow(
                              'Distance',
                              '${c.formatAmount(_numFrom(item['distance']))} km',
                              compact: true,
                            ),
                            _detailRow(
                              'Duration',
                              item['durationText']?.toString() ??
                                  '${_intFrom(item['durationMin'])} mins',
                              compact: true,
                            ),
                            _detailRow(
                              'Surge Multiplier',
                              '${_numFrom(item['surgeMultiplier']).toStringAsFixed(0)}x',
                              compact: true,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  if (summary.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Cost details are not available for this order.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    bool emphasize = false,
    bool compact = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: getTextStyle(
                fontSize: compact ? 13 : 14,
                color: Colors.grey.shade700,
                fontWeight: emphasize ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: getTextStyle(
              fontSize: compact ? 13 : 14,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  num _numFrom(dynamic value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value) ?? 0;
    }
    return 0;
  }

  int _intFrom(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
