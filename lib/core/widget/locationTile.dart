import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
import 'package:flutter/material.dart';

class LocationTile extends StatelessWidget {
  const LocationTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.isPickup,
    required this.pickupIconPath,
    required this.dropoffIconPath,
    this.trailingTopText,
    this.trailingBottomText,
  });

  final String title;
  final String subtitle;
  final String distance;
  final bool isPickup;
  final String? trailingTopText;
  final String? trailingBottomText;

  /// Custom override icons
  final String? pickupIconPath;
  final String? dropoffIconPath;

  @override
  Widget build(BuildContext context) {
    final iconPath = isPickup
        ? (pickupIconPath ?? IconPath.location_blue)
        : (dropoffIconPath ?? IconPath.location_red);
    final hasTrailingInfo =
        (trailingTopText?.trim().isNotEmpty ?? false) ||
        (trailingBottomText?.trim().isNotEmpty ?? false);
    final hasTitle = title.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: Center(
              child: Image.asset(
                iconPath,
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasTitle)
                  Text(
                    title,
                    style: getTextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                if (hasTitle) const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                // Padding(
                //   padding: const EdgeInsets.only(left: 30, top: 6),
                //   child: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Text(
                //         distance.split('|')[0].trim(),
                //         style: getTextStyle(
                //           fontSize: 10,
                //           color: Colors.grey,
                //           fontWeight: FontWeight.w600,
                //         ),
                //       ),
                //       SizedBox(width: 6),
                //       Container(width: 1, height: 14, color: Colors.grey),
                //       SizedBox(width: 6),
                //       if (distance.split('|').length > 1)
                //         Text(
                //           distance.split('|')[1].trim(),
                //           style: getTextStyle(
                //             fontSize: 10,
                //             fontWeight: FontWeight.w600,
                //             color: Colors.grey,
                //           ),
                //         ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),

          if (hasTrailingInfo) ...[
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (trailingTopText?.trim().isNotEmpty ?? false)
                  Text(
                    trailingTopText!,
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                if (trailingBottomText?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  Text(
                    trailingBottomText!,
                    style: getTextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
