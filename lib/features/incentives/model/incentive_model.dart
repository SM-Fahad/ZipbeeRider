class IncentiveModel {
  final int id;
  final int adminId;
  final String incentiveName;
  final String type;
  final DateTime? startDate;
  final DateTime? endDate;
  final int incentiveAmount;
  final String status;
  final DateTime createdAt;
  final String description;
  final String? claimExpire;
  final int? maxClaim;
  final int? priority;
  final String? rewardType;
  final String? claimType;
  final String? timeConstant;
  final List<IncentiveCollectionModel> collectedIncentives;

  IncentiveModel({
    required this.id,
    required this.adminId,
    required this.incentiveName,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.incentiveAmount,
    required this.status,
    required this.createdAt,
    this.description = '',
    this.claimExpire,
    this.maxClaim,
    this.priority,
    this.rewardType,
    this.claimType,
    this.timeConstant,
    this.collectedIncentives = const [],
  });

  bool get isActive {
    final normalizedStatus = status.toUpperCase();
    return normalizedStatus == 'ACTIVE' || normalizedStatus == 'ONGOING';
  }

  bool get isAutoClaim => claimType?.toUpperCase() == 'AUTO';

  bool isCollectedByUser(String? userId) {
    if (userId == null || userId.isEmpty) {
      return false;
    }

    return collectedIncentives.any(
      (item) => item.userId.toString() == userId && item.isCollected,
    );
  }

  factory IncentiveModel.fromJson(Map<String, dynamic> json) {
    return IncentiveModel(
      id: _readInt(json, ['id']),
      adminId: _readInt(json, ['adminId', 'admin_id']),
      incentiveName: _readString(json, ['incentive_name', 'name']),
      type: _readString(json, ['type', 'reward_type', 'claim_type']),
      startDate: _readDateTime(json, ['start_date', 'startDate']),
      endDate: _readDateTime(json, ['end_date', 'endDate']),
      incentiveAmount: _readInt(json, ['incentive_amount', 'reward_value']),
      status: _readString(json, ['status']),
      createdAt:
          _readDateTime(json, ['created_at', 'createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      description: _readString(json, ['description']),
      claimExpire: _readNullableString(json, ['claim_expire', 'claimExpire']),
      maxClaim: _readNullableInt(json, ['max_claim', 'max_clam']),
      priority: _readNullableInt(json, ['priority']),
      rewardType: _readNullableString(json, ['reward_type']),
      claimType: _readNullableString(json, ['claim_type']),
      timeConstant: _readNullableString(json, ['time_constant']),
      collectedIncentives: _readCollectedIncentives(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adminId': adminId,
      'incentive_name': incentiveName,
      'type': type,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'incentive_amount': incentiveAmount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'description': description,
      'claim_expire': claimExpire,
      'max_claim': maxClaim,
      'priority': priority,
      'reward_type': rewardType,
      'claim_type': claimType,
      'time_constant': timeConstant,
      'collected_incentives': collectedIncentives
          .map((item) => item.toJson())
          .toList(),
    };
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is String) {
        return value;
      }
      if (value != null) {
        return value.toString();
      }
    }
    return fallback;
  }

  static String? _readNullableString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }
      if (value is String) {
        return value;
      }
      return value.toString();
    }
    return null;
  }

  static int _readInt(
    Map<String, dynamic> json,
    List<String> keys, {
    int fallback = 0,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return fallback;
  }

  static int? _readNullableInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value);
      }
    }
    return null;
  }

  static DateTime? _readDateTime(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }

  static List<IncentiveCollectionModel> _readCollectedIncentives(
    Map<String, dynamic> json,
  ) {
    final value = json['collected_incentives'];
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => IncentiveCollectionModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}

class IncentiveCollectionModel {
  final int id;
  final int userId;
  final bool isCollected;
  final int incentiveId;

  const IncentiveCollectionModel({
    required this.id,
    required this.userId,
    required this.isCollected,
    required this.incentiveId,
  });

  factory IncentiveCollectionModel.fromJson(Map<String, dynamic> json) {
    return IncentiveCollectionModel(
      id: IncentiveModel._readInt(json, ['id']),
      userId: IncentiveModel._readInt(json, ['userId', 'user_id']),
      isCollected: json['is_collected'] == true || json['isCollected'] == true,
      incentiveId: IncentiveModel._readInt(json, [
        'incentiveId',
        'incentive_id',
      ]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'is_collected': isCollected,
      'incentiveId': incentiveId,
    };
  }
}
