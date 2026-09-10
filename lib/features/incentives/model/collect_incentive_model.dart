class CollectedIncentiveModel {
  final int id;
  final int userId;
  final int incentiveId;
  final int amount;
  final bool isCollected;
  final DateTime createdAt;

  CollectedIncentiveModel({
    required this.id,
    required this.userId,
    required this.incentiveId,
    required this.amount,
    required this.isCollected,
    required this.createdAt,
  });

  factory CollectedIncentiveModel.fromJson(Map<String, dynamic> json) {
    return CollectedIncentiveModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      incentiveId: json['incentiveId'] as int,
      amount: json['amount'] as int,
      isCollected: json['is_collected'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class WalletHistoryModel {
  final int id;
  final String transactionId;
  final String transactionType;
  final int userId;
  final String type;
  final String amount;
  final String status;
  final DateTime createdAt;

  WalletHistoryModel({
    required this.id,
    required this.transactionId,
    required this.transactionType,
    required this.userId,
    required this.type,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory WalletHistoryModel.fromJson(Map<String, dynamic> json) {
    return WalletHistoryModel(
      id: json['id'] is int ? json['id'] as int : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      transactionId: json['transactionId']?.toString() ?? json['id']?.toString() ?? '',
      transactionType: json['transactionType']?.toString() ?? '',
      userId: json['userId'] is int ? json['userId'] as int : (int.tryParse(json['userId']?.toString() ?? '0') ?? 0),
      type: json['type']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
    );
  }
}

class CollectIncentiveResponseModel {
  final CollectedIncentiveModel collectedIncentive;
  final Map<String, dynamic> user;
  final WalletHistoryModel walletHistory;

  CollectIncentiveResponseModel({
    required this.collectedIncentive,
    required this.user,
    required this.walletHistory,
  });

  factory CollectIncentiveResponseModel.fromJson(Map<String, dynamic> json) {
    return CollectIncentiveResponseModel(
      collectedIncentive: CollectedIncentiveModel.fromJson(
        json['collectedIncentive'] as Map<String, dynamic>,
      ),
      user: json['user'] as Map<String, dynamic>,
      walletHistory: WalletHistoryModel.fromJson(
        json['walletHistory'] as Map<String, dynamic>,
      ),
    );
  }
}
