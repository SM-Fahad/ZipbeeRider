class IncentiveStatsModel {
  final int countAll;
  final int countActiveRider;
  final int countOngoing;
  final double totalAmountGiven;

  IncentiveStatsModel({
    required this.countAll,
    required this.countActiveRider,
    required this.countOngoing,
    required this.totalAmountGiven,
  });

  factory IncentiveStatsModel.fromJson(Map<String, dynamic> json) {
    return IncentiveStatsModel(
      countAll: json['countAll'] as int,
      countActiveRider: json['countActiveRider'] as int,
      countOngoing: json['countOngoing'] as int,
      totalAmountGiven: (json['totalAmountGiven'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countAll': countAll,
      'countActiveRider': countActiveRider,
      'countOngoing': countOngoing,
      'totalAmountGiven': totalAmountGiven,
    };
  }
}
