import 'package:flutter/material.dart';

class IncentiveCollectAction extends StatelessWidget {
  const IncentiveCollectAction({
    super.key,
    required this.isCollected,
    required this.isCollecting,
    required this.isAutoClaim,
    required this.isActive,
    required this.onCollect,
    this.compact = false,
  });

  final bool isCollected;
  final bool isCollecting;
  final bool isAutoClaim;
  final bool isActive;
  final VoidCallback onCollect;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (isCollected) {
      return _StatusPill(
        label: 'Collected',
        color: Colors.green,
        compact: compact,
      );
    }

    if (isAutoClaim) {
      return _StatusPill(
        label: 'Auto claim',
        color: Colors.blueGrey,
        compact: compact,
      );
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.yellow[700] : Colors.grey.shade300,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 24,
          vertical: compact ? 8 : 10,
        ),
      ),
      onPressed: isActive && !isCollecting ? onCollect : null,
      child: isCollecting
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              compact ? 'Collect' : 'Collect Now',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 12 : 14,
              ),
            ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    required this.compact,
  });

  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 7 : 9,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: compact ? 12 : 13,
        ),
      ),
    );
  }
}
