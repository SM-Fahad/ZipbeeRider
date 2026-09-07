class EarningSummary {
  final bool success;
  final String message;
  final EarningSummaryData data;

  EarningSummary({
    required this.success,
    required this.message,
    required this.data,
  });

  factory EarningSummary.fromJson(Map<String, dynamic> json) {
    return EarningSummary(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: EarningSummaryData.fromJson(
        json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : <String, dynamic>{},
      ),
    );
  }
}

class EarningSummaryData {
  final List<EarningBucket> buckets;
  final int total;
  final int page;
  final int limit;
  final double totalEarning;

  EarningSummaryData({
    required this.buckets,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalEarning,
  });

  factory EarningSummaryData.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] is Map<String, dynamic>
        ? json['pagination'] as Map<String, dynamic>
        : <String, dynamic>{};
    final rawBuckets = json['data'] as List<dynamic>? ?? const [];

    return EarningSummaryData(
      buckets: rawBuckets
          .whereType<Map>()
          .map(
            (item) => EarningBucket.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      total: _readInt(pagination['total']),
      page: _readInt(pagination['page'], fallback: 1),
      limit: _readInt(pagination['limit'], fallback: 10),
      totalEarning: _readDouble(json['totalEarning']),
    );
  }
}

class EarningBucket {
  final String date;
  final double total;

  EarningBucket({required this.date, required this.total});

  factory EarningBucket.fromJson(Map<String, dynamic> json) {
    return EarningBucket(
      date: json['date']?.toString() ?? '',
      total: _readDouble(json['total']),
    );
  }
}

double _readDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

int _readInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}
