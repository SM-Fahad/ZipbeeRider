class UserModel {
  final int id;
  final String username;
  final String email;
  final String phone;
  final String rewardPoints;
  final bool isActive;
  final bool isVerified;
  final String totalWalletBalance;
  final String currentWalletBalance;
  final String totalCoinAcc;
  final String currentCoinBalance;
  final String? fcmToken;
  final String? image;
  final String roleId;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.rewardPoints,
    required this.isActive,
    required this.isVerified,
    required this.totalWalletBalance,
    required this.currentWalletBalance,
    required this.totalCoinAcc,
    required this.currentCoinBalance,
    this.fcmToken,
    this.image,
    required this.roleId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _readInt(json, ['id']),
      username: _readString(json, ['username', 'name']),
      email: _readString(json, ['email']),
      phone: _readString(json, ['phone', 'phone_number']),
      rewardPoints: _readString(json, ['reward_points'], fallback: '0'),
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? true,
      totalWalletBalance: _readString(json, [
        'totalWalletBalance',
        'total_wallet_balance',
      ], fallback: '0'),
      currentWalletBalance: _readString(json, [
        'currentWalletBalance',
        'current_wallet_balance',
      ], fallback: '0'),
      totalCoinAcc: _readString(json, ['total_coin_acc'], fallback: '0'),
      currentCoinBalance: _readString(json, [
        'current_coin_balance',
      ], fallback: '0'),
      fcmToken: _readNullableString(json, ['fcmToken', 'fcm_token']),
      image: _readNullableString(json, ['image']),
      roleId: _readString(json, ['roleId', 'role_id'], fallback: '0'),
      createdAt:
          _readDateTime(json, ['created_at', 'createdAt']) ?? DateTime.now(),
      updatedAt:
          _readDateTime(json, ['updated_at', 'updatedAt']) ?? DateTime.now(),
    );
  }

  // Empty constructor for fallback
  factory UserModel.empty() {
    return UserModel(
      id: 0,
      username: '',
      email: '',
      phone: '',
      rewardPoints: "0",
      isActive: false,
      isVerified: false,
      totalWalletBalance: "0",
      currentWalletBalance: "0",
      totalCoinAcc: "0",
      currentCoinBalance: "0",
      fcmToken: null,
      image: null,
      roleId: "0",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'reward_points': rewardPoints,
      'is_active': isActive,
      'is_verified': isVerified,
      'totalWalletBalance': totalWalletBalance,
      'currentWalletBalance': currentWalletBalance,
      'total_coin_acc': totalCoinAcc,
      'current_coin_balance': currentCoinBalance,
      'fcmToken': fcmToken,
      'image': image,
      'roleId': roleId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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
}
