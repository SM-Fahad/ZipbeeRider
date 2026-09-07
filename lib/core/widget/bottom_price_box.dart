import 'package:flutter/material.dart';

import '../../../core/utils/constants/iconpath.dart';

class BottomPriceBox extends StatelessWidget {
  final String distance;
  final String price;
  final String? vehicleType;
  final String? totalCost;
  final String? additionalCost;
  final String? additionalServiceFee;
  final String? routeType;

  const BottomPriceBox({
    super.key,
    required this.distance,
    required this.price,
    this.vehicleType,
    this.totalCost,
    this.additionalCost,
    this.additionalServiceFee,
    this.routeType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                routeType == 'ROUND'
                    ? IconPath.roundtrip
                    : routeType == 'ONE_WAY'
                        ? IconPath.oneway
                        : IconPath.exparess,
                width: 24,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.local_shipping_outlined,
                  color: Colors.grey,
                  size: 24,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Total Distance',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(distance, style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Rider Earning',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (totalCost != null) ...[
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order Total Cost',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  totalCost!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
          if (additionalCost != null) ...[
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Additional Cost',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  additionalCost!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
          if (additionalServiceFee != null) ...[
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Additional Service Fee',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  additionalServiceFee!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
