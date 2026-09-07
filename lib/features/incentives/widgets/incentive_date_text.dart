import 'package:flutter/material.dart';

String incentiveDateText({
  required DateTime? startDate,
  required DateTime? endDate,
}) {
  if (startDate != null && endDate != null) {
    return 'Valid: ${_formatDate(startDate)} - ${_formatDate(endDate)}';
  }
  if (startDate != null) {
    return 'Started: ${_formatDate(startDate)}';
  }
  if (endDate != null) {
    return 'Expire: ${_formatDate(endDate)}';
  }
  return '';
}

Widget incentiveDateLabel({
  required DateTime? startDate,
  required DateTime? endDate,
  TextStyle? style,
}) {
  final text = incentiveDateText(startDate: startDate, endDate: endDate);
  if (text.isEmpty) {
    return const SizedBox.shrink();
  }

  return Text(
    text,
    style: style ?? const TextStyle(fontSize: 11, color: Colors.black38),
  );
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
