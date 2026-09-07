import 'package:ZipBee_Driver/core/utils/constants/image_path.dart';
import 'package:flutter/material.dart';

class IncentiveTierHeader extends StatelessWidget {
  const IncentiveTierHeader({super.key, required this.currentTier});

  final String currentTier;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Your current tier',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          currentTier,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Image.asset(_tierImage(currentTier), height: 120),
        const SizedBox(height: 20),
        Row(
          children: [
            _stepIcon(
              ImagePath.bronze,
              active: currentTier.toUpperCase() == 'BRONZE',
            ),
            _line(),
            _stepIcon(
              ImagePath.silver,
              active: currentTier.toUpperCase() == 'SILVER',
            ),
            _line(),
            _stepIcon(
              ImagePath.gold,
              active: currentTier.toUpperCase() == 'GOLD',
            ),
            _line(),
            _stepIcon(
              ImagePath.diamond,
              active: currentTier.toUpperCase() == 'PLATINUM',
            ),
          ],
        ),
      ],
    );
  }

  static String _tierImage(String tier) {
    switch (tier.toUpperCase()) {
      case 'BRONZE':
        return ImagePath.bronze;
      case 'SILVER':
        return ImagePath.silver;
      case 'GOLD':
        return ImagePath.gold;
      case 'PLATINUM':
        return ImagePath.diamond;
      default:
        return ImagePath.gold;
    }
  }

  static Widget _stepIcon(String path, {bool active = false}) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: active ? Colors.yellow[700] : Colors.grey[300],
      child: Image.asset(path, height: 22),
    );
  }

  static Widget _line() {
    return Expanded(child: Container(height: 2, color: Colors.grey[300]));
  }
}
