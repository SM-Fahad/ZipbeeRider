class HomeOrderModel {
  final String type;
  final String code;
  final String pickup;
  final String delivery;
  final String price;
  final String time;
  final String status;
  final String buttonText;
  final String screenType;
  final String rightButtonText;
  final String collectTime; // 'ASAP' or 'SCHEDULED'
  final String? scheduledTime;
  final double? distanceKm;
  final int? estimatedTimeMinutes;

  HomeOrderModel({
    required this.type,
    required this.code,
    required this.pickup,
    required this.delivery,
    required this.price,
    required this.time,
    required this.status,
    required this.buttonText,
    required this.screenType,
    required this.rightButtonText,
    required this.collectTime,
    this.scheduledTime,
    this.distanceKm,
    this.estimatedTimeMinutes,
  });

  /// ✅ copyWith (VERY IMPORTANT)
  HomeOrderModel copyWith({
    String? type,
    String? code,
    String? pickup,
    String? delivery,
    String? price,
    String? time,
    String? status,
    String? buttonText,
    String? screenType,
    String? rightButtonText,
    String? collectTime,
    String? scheduledTime,
    double? distanceKm,
    int? estimatedTimeMinutes,
  }) {
    return HomeOrderModel(
      type: type ?? this.type,
      code: code ?? this.code,
      pickup: pickup ?? this.pickup,
      delivery: delivery ?? this.delivery,
      price: price ?? this.price,
      time: time ?? this.time,
      status: status ?? this.status,
      buttonText: buttonText ?? this.buttonText,
      screenType: screenType ?? this.screenType,
      rightButtonText: rightButtonText ?? this.rightButtonText,
      collectTime: collectTime ?? this.collectTime,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedTimeMinutes: estimatedTimeMinutes ?? this.estimatedTimeMinutes,
    );
  }
}
