import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/common/widgets/custom_button.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/support/user_support/help_center/controller/dispute_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DisputeDetailsScreen extends StatelessWidget {
  const DisputeDetailsScreen({
    super.key,
    this.disputeId,
    this.orderId,
    this.dispute,
  });

  final int? disputeId;
  final int? orderId;
  final Map<String, dynamic>? dispute;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      DisputeDetailsController(
        disputeId: disputeId,
        orderId: orderId,
        initialDispute: dispute,
      ),
      tag: '${disputeId}_$orderId',
    );

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroungColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Dispute Details',
          style: getTextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final disputeData = controller.dispute.value;

        if (disputeData == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 56,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value ??
                        'Unable to load dispute details',
                    textAlign: TextAlign.center,
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchDetails(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButtonColor,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final status = disputeData['status']?.toString().toUpperCase() ?? 'UNKNOWN';
        final disputeType =
            disputeData['disputeType'] as Map<String, dynamic>? ?? {};
        final issueType =
            disputeType['name']?.toString() ?? 'Issue with order';
        final description =
            disputeData['description']?.toString() ?? 'No description provided';
        final adminNote = disputeData['adminNote']?.toString().trim();
        final createdAt = _formatDate(disputeData['created_at']?.toString());
        final resolvedAt = _formatDate(disputeData['resolvedAt']?.toString());
        final evidence = (disputeData['evidence'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList();
        final proofImageUrl = evidence.isNotEmpty ? evidence.first : null;
        final currentAppeal = controller.appeal.value;

        return RefreshIndicator(
          onRefresh: () => controller.fetchDetails(showLoader: false),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Order & Status Overview Card
                _CardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order ID',
                                  style: getTextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  controller.displayOrderNumber,
                                  style: getTextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryFontColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _StatusBadge(status: status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      _DetailRow(label: 'Dispute Reason', value: issueType),
                      const SizedBox(height: 8),
                      _DetailRow(label: 'Date Filed', value: createdAt),
                      if (resolvedAt != '-') ...[
                        const SizedBox(height: 8),
                        _DetailRow(label: 'Date Resolved', value: resolvedAt),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 2. Financial Outcome Card (Formatted to 2 decimals)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF3DE92)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAD752),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Financial Outcome',
                              style: getTextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Deduction from Wallet: ${controller.formattedDeductionAmount}',
                              style: getTextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 3. Customer Claim & Evidence Card
                _CardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Claim Details',
                        style: getTextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryFontColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        description,
                        style: getTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          lineHeight: 1.4,
                        ),
                      ),
                      if (proofImageUrl != null) ...[
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Customer Proof:',
                              style: getTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  _showImagePreview(context, proofImageUrl),
                              child: Text(
                                'View Image',
                                style: getTextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (adminNote != null && adminNote.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Text(
                          'Admin Resolution Note:',
                          style: getTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          adminNote,
                          style: getTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 4. Appeal Card / Action Flow
                if (currentAppeal != null) ...[
                  _CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Appeal',
                              style: getTextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryFontColor,
                              ),
                            ),
                            _AppealStatusBadge(
                              status: currentAppeal['status']?.toString() ??
                                  'PENDING',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          label: 'Submitted',
                          value: _formatDate(
                            currentAppeal['createdAt']?.toString(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Driver Statement:',
                          style: getTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentAppeal['reason']?.toString() ?? '-',
                          style: getTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            lineHeight: 1.4,
                          ),
                        ),
                        if (currentAppeal['fileUrl'] != null &&
                            currentAppeal['fileUrl'].toString().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                'Attached Proof:',
                                style: getTextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _showImagePreview(
                                  context,
                                  currentAppeal['fileUrl'].toString(),
                                ),
                                child: Text(
                                  'View Photo',
                                  style: getTextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (currentAppeal['adminRemarks'] != null &&
                            currentAppeal['adminRemarks']
                                .toString()
                                .trim()
                                .isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          Text(
                            'Admin Remarks:',
                            style: getTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentAppeal['adminRemarks'].toString().trim(),
                            style: getTextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ] else if (controller.canFileAppeal) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF0E2A2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFFC48800),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Not your fault? You have 48 hours to Appeal.',
                                style: getTextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'If you completed delivery correctly or have delivery proof, submit an appeal for penalty reversal.',
                          style: getTextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        CustomButton(
                          label: 'File Appeal',
                          onPressed: controller.openCreateAppeal,
                          color: AppColors.primaryButtonColor,
                          textColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  static String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(value).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
    } catch (_) {
      return value;
    }
  }

  static void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(dialogContext).size.height * 0.6,
                  ),
                  child: InteractiveViewer(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Unable to load image preview',
                          style: getTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            '$label:',
            style: getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.primaryButtonColor;
    Color fg = Colors.black;

    if (status == 'RESOLVED') {
      bg = const Color(0xFFE6F7ED);
      fg = const Color(0xFF1E824C);
    } else if (status == 'REJECTED') {
      bg = const Color(0xFFFFECEC);
      fg = const Color(0xFFD63031);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: getTextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

class _AppealStatusBadge extends StatelessWidget {
  const _AppealStatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    String label = 'Appeal Under Review';
    Color bg = const Color(0xFFFFF4C2);
    Color fg = const Color(0xFF8A6D00);

    final upper = status.toUpperCase();
    if (upper == 'ACCEPTED') {
      label = 'Appeal Accepted';
      bg = const Color(0xFFE6F7ED);
      fg = const Color(0xFF1E824C);
    } else if (upper == 'REJECTED') {
      label = 'Appeal Rejected';
      bg = const Color(0xFFFFECEC);
      fg = const Color(0xFFD63031);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: getTextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
