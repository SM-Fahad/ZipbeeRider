import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/auth/login/controller/profile_check_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ApplicationRejectedScreen extends StatelessWidget {
  ApplicationRejectedScreen({super.key});

  final ProfileCheckController controller =
      Get.isRegistered<ProfileCheckController>()
          ? Get.find<ProfileCheckController>()
          : Get.put(ProfileCheckController());

  String _formatRejectedDate(String isoString) {
    if (isoString.trim().isEmpty) return '';
    try {
      final parsed = DateTime.parse(isoString.trim()).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Application Status',
          style: getTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryFontColor,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () => controller.signOut(),
          ),
        ],
      ),
      body: Obx(
        () => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Status Icon & Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEB),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFCDD2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.cancel_outlined,
                          size: 46,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Application Rejected',
                        style: getTextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFD32F2F),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your driver registration requires revisions',
                        textAlign: TextAlign.center,
                        style: getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.subtitleFontColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Driver Account Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7D6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primaryFontColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.username.value.isNotEmpty
                                  ? controller.username.value
                                  : 'Driver Applicant',
                              style: getTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryFontColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              controller.email.value.isNotEmpty
                                  ? controller.email.value
                                  : controller.phone.value,
                              style: getTextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.subtitleFontColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Rejection Reason Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFFFCDD2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 20,
                            color: Color(0xFFD32F2F),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'REASON FOR REJECTION',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFD32F2F),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8F8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFEBEE)),
                        ),
                        child: Text(
                          controller.rejectionReason.value.isNotEmpty
                              ? controller.rejectionReason.value
                              : 'Admin has requested changes to your submitted documents or information.',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                      if (controller.rejectedAt.value.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppColors.subtitleFontColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Reviewed on ${_formatRejectedDate(controller.rejectedAt.value)}',
                              style: getTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.subtitleFontColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Next steps instructions
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What you need to do:',
                        style: getTextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryFontColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildBulletPoint(
                        'Tap "Edit & Resubmit Details" below to review your information.',
                      ),
                      const SizedBox(height: 6),
                      _buildBulletPoint(
                        'Replace or update the requested document (e.g. upload a clear driving license).',
                      ),
                      const SizedBox(height: 6),
                      _buildBulletPoint(
                        'Submit the form again for admin approval.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Primary Action: Edit & Resubmit Details
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.startResubmission(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButtonColor,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 54),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit_note_rounded, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Edit & Resubmit Details',
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Re-Check Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.recheckProfile,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: const BorderSide(
                        color: AppColors.primaryButtonColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Re-Check Status',
                            style: getTextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryFontColor,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: controller.isSigningOut.value
                        ? null
                        : controller.signOut,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFD32F2F),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: controller.isSigningOut.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFD32F2F),
                            ),
                          )
                        : Text(
                            'Sign Out',
                            style: getTextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFD32F2F),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(
            Icons.circle,
            size: 6,
            color: AppColors.subtitleFontColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.fontColor,
            ),
          ),
        ),
      ],
    );
  }
}
