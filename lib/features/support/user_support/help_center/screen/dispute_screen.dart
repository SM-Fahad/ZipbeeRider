import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/support/user_support/help_center/controller/dispute_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DisputeScreen extends StatelessWidget {
  const DisputeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DisputeController>()
        ? Get.find<DisputeController>()
        : Get.put(DisputeController());

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
          'Support & Dispute',
          style: getTextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.disputes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshDisputes,
          child: ListView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: controller.openCreateDispute,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4C2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_task_outlined,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Report an Issue',
                                style: getTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryFontColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Report an issue with your order and upload proof if needed.',
                                style: getTextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dispute History',
                                  style: getTextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Track your previous dispute requests here.',
                                  style: getTextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4C2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${controller.totalCount.value}',
                              style: getTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (controller.disputes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFDF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE9E0BC)),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.history_toggle_off_rounded,
                                size: 42,
                                color: Colors.black45,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No dispute history found',
                                style: getTextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (controller.disputes.isNotEmpty)
                      ...List.generate(controller.disputes.length, (index) {
                        final dispute = controller.disputes[index];
                        return Column(
                          children: [
                            if (index != 0)
                              const Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: _DisputeHistoryCard(
                                dispute: dispute,
                                onAppeal: controller.openCreateAppeal,
                              ),
                            ),
                          ],
                        );
                      }),
                    if (controller.isLoadingMore.value)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _DisputeHistoryCard extends StatelessWidget {
  const _DisputeHistoryCard({
    required this.dispute,
    required this.onAppeal,
  });

  final Map<String, dynamic> dispute;
  final Future<void> Function({
    required int orderDisputeId,
    required int orderId,
  })
  onAppeal;

  @override
  Widget build(BuildContext context) {
    final disputeType = dispute['disputeType'] as Map<String, dynamic>? ?? {};
    final issueType = disputeType['name']?.toString() ?? 'Unknown';
    final status = dispute['status']?.toString() ?? 'UNKNOWN';
    final orderId = dispute['orderId']?.toString() ?? '-';
    final description = dispute['description']?.toString() ?? '';
    final adminNote = dispute['adminNote']?.toString().trim();
    final evidence = (dispute['evidence'] as List<dynamic>? ?? [])
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();
    final proofImageUrl = evidence.isNotEmpty ? evidence.first : null;
    final createdAt = _formatDate(dispute['created_at']?.toString());
    final refundAmount = _formatRefundAmount(
      status: status,
      amount: dispute['refundAmount']?.toString(),
    );
    final disputeAppeals = (dispute['disputeAppeals'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    final appeal = disputeAppeals.isNotEmpty ? disputeAppeals.first : null;
    final canAppeal = _canShowAppealPrompt(
      status: status,
      resolvedAt: dispute['resolvedAt']?.toString(),
      disputeAppeals: disputeAppeals,
    );
    final disputeId = _readInt(dispute['id']);
    final orderIdValue = _readInt(dispute['orderId']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Order #$orderId',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryFontColor,
                ),
              ),
            ),
            _StatusBadge(label: status),
          ],
        ),
        const SizedBox(height: 12),
        _InfoRow(label: 'Issue', value: issueType),
        // const SizedBox(height: 8),
        // _InfoRow(label: 'Priority', value: priority),
        const SizedBox(height: 8),
        _InfoRow(label: 'Created', value: createdAt),
        if (refundAmount != null) ...[
          const SizedBox(height: 8),
          _InfoRow(label: 'Refund', value: refundAmount),
        ],
        SizedBox(height: 8),
        _InfoRow(label: 'Description', value: description),
        if (proofImageUrl != null) ...[
          const SizedBox(height: 8),
          _ProofRow(imageUrl: proofImageUrl),
        ],
        if (status.toUpperCase() != 'PENDING') ...[
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Admin Note',
            value: (adminNote == null || adminNote.isEmpty) ? 'N/A' : adminNote,
          ),
          if (appeal != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Appeal Status',
              value: appeal['status']?.toString() ?? 'UNKNOWN',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Appeal Note',
              value: _formatNullableText(appeal['adminNote']),
            ),
          ] else if (canAppeal && disputeId != null && orderIdValue != null) ...[
            const SizedBox(height: 12),
            _AppealPrompt(
              onPressed: () => onAppeal(
                orderDisputeId: disputeId,
                orderId: orderIdValue,
              ),
            ),
          ],
        ],
      ],
    );
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(value).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
    } catch (_) {
      return value;
    }
  }

  String? _formatRefundAmount({
    required String status,
    required String? amount,
  }) {
    if (status.toUpperCase() != 'RESOLVED' ||
        amount == null ||
        amount.isEmpty) {
      return null;
    }

    final parsed = double.tryParse(amount);
    if (parsed == null) {
      return amount;
    }

    return parsed.toStringAsFixed(2);
  }

  bool _canShowAppealPrompt({
    required String status,
    required String? resolvedAt,
    required List<Map<String, dynamic>> disputeAppeals,
  }) {
    if (status.toUpperCase() != 'RESOLVED' || disputeAppeals.isNotEmpty) {
      return false;
    }
    if (resolvedAt == null || resolvedAt.isEmpty) return false;

    try {
      final resolvedTime = DateTime.parse(resolvedAt).toLocal();
      final appealDeadline = resolvedTime.add(const Duration(hours: 48));
      return DateTime.now().isBefore(appealDeadline) ||
          DateTime.now().isAtSameMomentAs(appealDeadline);
    } catch (_) {
      return false;
    }
  }

  int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String _formatNullableText(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? 'N/A' : text;
  }
}

class _AppealPrompt extends StatelessWidget {
  const _AppealPrompt({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0E2A2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Not you fault? You have 48 hour to Appeal.',
              style: getTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryButtonColor,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Appeal',
              style: getTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProofRow extends StatelessWidget {
  const _ProofRow({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final imageName = _extractImageName(imageUrl);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            'Proof:',
            style: getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Text(
                imageName,
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () => _showImagePreview(context, imageUrl),
                child: Text(
                  'Click to view',
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _extractImageName(String url) {
    final parsedUri = Uri.tryParse(url);
    final lastSegment = parsedUri?.pathSegments.isNotEmpty == true
        ? parsedUri!.pathSegments.last
        : url.split('/').last;
    return lastSegment.isEmpty ? 'Proof Image' : lastSegment;
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          backgroundColor: Colors.white,
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
                          'Unable to load proof image',
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
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
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryButtonColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: getTextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),
    );
  }
}
