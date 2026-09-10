import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/features/wallet_history/controller/wallet_controller.dart';
import 'package:ZipBee_Driver/features/wallet_history/model/wallet_history_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WalletHistoryScreen extends StatelessWidget {
  const WalletHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Transaction History",
              style: getTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: GetBuilder<WalletHistoryController>(
        init: WalletHistoryController(),
        builder: (controller) {
          return Column(
            children: [
              // Filter Chips / Tabs (All vs Tips)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: "All Transactions",
                      icon: Icons.receipt_long_outlined,
                      isSelected: controller.selectedFilter == 'ALL',
                      onTap: () => controller.setFilter('ALL'),
                    ),
                    const SizedBox(width: 10),
                    _buildFilterChip(
                      label: "Tips",
                      icon: Icons.volunteer_activism,
                      isSelected: controller.selectedFilter == 'TIP',
                      activeColor: const Color(0xFFF59E0B),
                      onTap: () => controller.setFilter('TIP'),
                    ),
                  ],
                ),
              ),

              // Transaction List
              Expanded(
                child: controller.transactions.isEmpty && !controller.isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              controller.selectedFilter == 'TIP'
                                  ? Icons.volunteer_activism_outlined
                                  : Icons.receipt_long_outlined,
                              size: 56,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              controller.selectedFilter == 'TIP'
                                  ? 'No tips received yet'
                                  : 'No transactions yet',
                              style: getTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: controller.refreshData,
                        child: ListView.builder(
                          controller: controller.scrollController,
                          padding: const EdgeInsets.all(12),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: controller.transactions.length +
                              (controller.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < controller.transactions.length) {
                              final item = controller.transactions[index];
                              return _buildTransactionCard(item);
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Loading more...',
                                      style: getTextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Color activeColor = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: getTextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(WalletHistory item) {
    final isCredit = item.isCredit;
    final isTip = item.isTip;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTip ? const Color(0xFFFDE68A) : Colors.grey.shade200,
          width: isTip ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isTip
                ? const Color(0xFFF59E0B).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon, transaction type/badge and amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isTip
                      ? const Color(0xFFFEF3C7)
                      : (isCredit ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isTip
                      ? Icons.volunteer_activism
                      : (isCredit ? Icons.arrow_downward : Icons.arrow_upward),
                  size: 20,
                  color: isTip
                      ? const Color(0xFFD97706)
                      : (isCredit ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                ),
              ),
              const SizedBox(width: 12),

              // Title and Message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.displayTitle,
                          style: getTextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        if (isTip) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFCD34D)),
                            ),
                            child: Text(
                              "TIP",
                              style: getTextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (item.message.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        style: getTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isCredit ? '+' : '-'} \$${item.amount}",
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isCredit ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                    ),
                  ),
                  if (item.currency.isNotEmpty)
                    Text(
                      item.currency,
                      style: getTextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 8),

          // Footer with date and status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(item.createdAt),
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.status.toUpperCase() == 'SUCCESS'
                      ? const Color(0xFFDCFCE7)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.status,
                  style: getTextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: item.status.toUpperCase() == 'SUCCESS'
                        ? const Color(0xFF16A34A)
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}