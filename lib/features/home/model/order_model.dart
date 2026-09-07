import 'user_model.dart';
import 'vehicle_model.dart';
import 'order_stop_model.dart';
import 'package:ZipBee_Driver/core/utils/delivery_type_icon_helper.dart';

class OrderModel {
  final int id;
  final int? serviceZoneId;
  final int userId;
  final String routeType; // ONE_WAY, ROUND, MULTI
  final String deliveryType; // EXPRESS, STANDARD
  final String? deliveryTypeIcon;
  final int deliveryTypeId;
  final String payType; // COD, PREPAID
  final String collectTime; // ASAP, SCHEDULED
  final DateTime? scheduledTime;
  final int vehicleTypeId;
  final String totalCost;
  final String totalFee;
  final String? additionalCost;
  final String? commission;
  final String? refundAmount;
  final bool hasAdditionalServices;
  final bool isPromoUsed;
  final bool notifyFavoriteRider;
  final int? paymentMethodId;
  final List<dynamic> competitorId;
  final DateTime? competitionStartedAt;
  final bool competitionClosed;
  final int? assignRiderId;
  final DateTime? assignAt;
  final int? collectionTime;
  final String? collectionUnit;
  final bool raiderConfirmation;
  final bool isAutoConfirmation;
  final DateTime? userConfirmationAt;
  final bool isReviewed;
  final bool isPlaced;
  final DateTime? placedAt;
  final bool isPickup;
  final String
  orderStatus; // PENDING, ACCEPTED, IN_PROGRESS, COMPLETED, CANCELLED
  final bool isOutForDelivery;
  final bool isFixed;
  final bool isDispute;
  final bool isBulk;
  final List<dynamic> pickUpItems;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel user;
  final VehicleModel vehicle;
  final List<OrderStopModel> orderStops;
  final String buttonText;
  final String rightButtonText;
  final Map<String, dynamic>? pricingSummary;
  final double? distanceKm;
  final double? totalRaiderEarnings;
  final double? additionalServiceFee;
  final int? totalTime;
  final double? raiderToPickupKm;
  final double? basePay;
  final double? extraFee;
  final int? dropCount;
  final String? section;
  final int? sectionRank;
  final String? sectionLabel;
  final String? sectionColor;
  final String? primarySectionColor;

  OrderModel({
    required this.id,
    this.serviceZoneId,
    required this.userId,
    required this.routeType,
    required this.deliveryType,
    this.deliveryTypeIcon,
    required this.deliveryTypeId,
    required this.payType,
    required this.collectTime,
    this.scheduledTime,
    required this.vehicleTypeId,
    required this.totalCost,
    required this.totalFee,
    this.additionalCost,
    this.commission,
    this.refundAmount,
    required this.hasAdditionalServices,
    required this.isPromoUsed,
    required this.notifyFavoriteRider,
    this.paymentMethodId,
    required this.competitorId,
    this.competitionStartedAt,
    required this.competitionClosed,
    this.assignRiderId,
    this.assignAt,
    this.collectionTime,
    this.collectionUnit,
    required this.raiderConfirmation,
    required this.isAutoConfirmation,
    this.userConfirmationAt,
    required this.isReviewed,
    required this.isPlaced,
    this.placedAt,
    required this.isPickup,
    required this.orderStatus,
    required this.isOutForDelivery,
    required this.isFixed,
    required this.isDispute,
    required this.isBulk,
    required this.pickUpItems,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.vehicle,
    required this.orderStops,
    required this.buttonText,
    required this.rightButtonText,
    this.pricingSummary,
    this.distanceKm,
    this.totalRaiderEarnings,
    this.additionalServiceFee,
    this.totalTime,
    this.raiderToPickupKm,
    this.basePay,
    this.extraFee,
    this.dropCount,
    this.section,
    this.sectionRank,
    this.sectionLabel,
    this.sectionColor,
    this.primarySectionColor,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final orderId = _readInt(json, ['id']);
    final rawOrderStops = json['orderStops'] as List? ?? [];
    final rawDestinations = json['destinations'] as List? ?? [];
    final vehicleJson = _resolveVehicleJson(json);
    final pricingSummary = _readMap(json, ['pricingSummary']);
    final feedMeta = _readMap(json, ['feedMeta']);

    final sectionVal = _readNullableString(json, ['section']) ??
        _readNullableString(feedMeta, ['section']);
    final sectionRankVal = _readNullableInt(json, ['sectionRank', 'section_rank']) ??
        _readNullableInt(feedMeta, ['sectionRank', 'section_rank']);
    final sectionLabelVal = _readNullableString(json, ['sectionLabel', 'section_label']) ??
        _readNullableString(feedMeta, ['sectionLabel', 'section_label']);
    final sectionColorVal = _readNullableString(json, ['sectionColor', 'section_color']) ??
        _readNullableString(feedMeta, ['sectionColor', 'section_color']);
    final primarySectionColorVal = _readNullableString(json, ['primarySectionColor', 'primary_section_color']) ??
        _readNullableString(feedMeta, ['primarySectionColor', 'primary_section_color']);

    return OrderModel(
      id: orderId,
      serviceZoneId: _readNullableInt(json, [
        'serviceZoneId',
        'service_zone_id',
      ]),
      userId: _readInt(json, ['userId', 'user_id']),
      routeType: _readString(json, ['route_type'], fallback: 'ONE_WAY'),
      deliveryType: _readDeliveryType(json),
      deliveryTypeIcon: _readDeliveryTypeIcon(json),
      deliveryTypeId: _readDeliveryTypeId(json),
      payType: _readString(json, ['pay_type'], fallback: 'COD'),
      collectTime: _readString(json, ['collect_time'], fallback: 'ASAP'),
      scheduledTime: _readDateTime(json, ['scheduled_time']),
      vehicleTypeId: _readInt(json, ['vehicle_type_id']),
      totalCost: _readString(json, ['total_cost'], fallback: '0'),
      totalFee: _readString(json, ['total_fee'], fallback: '0'),
      additionalCost: _readNullableString(json, ['additional_cost']),
      commission: _readNullableString(json, ['commission']),
      refundAmount: _readNullableString(json, ['refund_amount']),
      hasAdditionalServices: _readBool(json, ['has_additional_services']),
      isPromoUsed: _readBool(json, ['is_promo_used']),
      notifyFavoriteRider: _readBool(json, ['notify_favorite_raider']),
      paymentMethodId: _readNullableInt(json, ['payment_method_id']),
      competitorId: json['compititor_id'] as List? ?? [],
      competitionStartedAt: _readDateTime(json, ['competition_started_at']),
      competitionClosed: _readBool(json, ['competition_closed']),
      assignRiderId: _readNullableInt(json, ['assign_rider_id']),
      assignAt: _readDateTime(json, ['assign_at', 'assignAt']),
      collectionTime: _readDeliveryTypeCollectionTime(json),
      collectionUnit: _readDeliveryTypeCollectionUnit(json),
      raiderConfirmation: _readBool(json, ['raider_confirmation']),
      isAutoConfirmation: _readBool(json, ['is_auto_confirmation']),
      userConfirmationAt: _readDateTime(json, ['user_confirmation_at', 'userConfirmationAt']),
      isReviewed: _readBool(json, ['is_reviewed']),
      isPlaced: _readBool(json, ['is_placed']),
      placedAt: _readDateTime(json, ['placed_at', 'placedAt']),
      isPickup: _readBool(json, ['is_pickup']),
      orderStatus: _readString(json, ['order_status'], fallback: 'PENDING'),
      isOutForDelivery: _readBool(json, ['is_out_for_delivery']),
      isFixed: _readBool(json, ['isFixed']),
      isDispute: _readBool(json, ['isDispute']),
      isBulk: _readBool(json, ['isBulk']),
      pickUpItems: json['pick_up_items'] as List? ?? [],
      createdAt: _readDateTime(json, ['created_at']) ?? DateTime.now(),
      updatedAt: _readDateTime(json, ['updated_at']) ?? DateTime.now(),
      user: json['user'] != null
          ? UserModel.fromJson(
              json['user'] is Map
                  ? Map<String, dynamic>.from(json['user'])
                  : json['user'] as Map<String, dynamic>,
            )
          : UserModel.empty(),
      vehicle: vehicleJson.isNotEmpty
          ? VehicleModel.fromJson(vehicleJson)
          : VehicleModel.empty(),
      orderStops: rawOrderStops.isNotEmpty
          ? rawOrderStops
                .whereType<Map>()
                .map(
                  (stop) =>
                      OrderStopModel.fromJson(Map<String, dynamic>.from(stop)),
                )
                .toList()
          : rawDestinations
                .asMap()
                .entries
                .where((entry) => entry.value is Map)
                .map(
                  (entry) => OrderStopModel.fromDestinationJson(
                    Map<String, dynamic>.from(entry.value as Map),
                    orderId: orderId,
                    index: entry.key,
                  ),
                )
                .toList(),
      buttonText: _readString(json, ['button_text'], fallback: 'Accept'),
      rightButtonText: _readString(json, [
        'right_button_text',
      ], fallback: 'Decline'),
      pricingSummary: pricingSummary.isEmpty ? null : pricingSummary,
      distanceKm:
          _readNullableDouble(pricingSummary, ['totalDistance']) ??
          _readNullableDouble(json, ['distance_km', 'total_distance']),
      totalRaiderEarnings:
          _readNullableDouble(pricingSummary, ['totalRaiderEarnings']) ??
          _readNullableDouble(json, [
            'total_raider_earnings',
            'totalRaiderEarnings',
          ]),
      additionalServiceFee: _readNullableDouble(pricingSummary, [
        'additionServiceFee',
      ]),
      totalTime: _readNullableInt(json, ['total_time', 'totalTime']),
      raiderToPickupKm: _readNullableDouble(feedMeta, ['raiderToPickupKm']),
      basePay: _readNullableDouble(json, ['basePay', 'base_pay']) ??
          _readNullableDouble(feedMeta, ['basePay', 'base_pay']),
      extraFee: _readNullableDouble(json, ['extraFee', 'extra_fee']) ??
          _readNullableDouble(feedMeta, ['extraFee', 'extra_fee']),
      dropCount: _readNullableInt(json, ['dropCount', 'drop_count']) ??
          _readNullableInt(feedMeta, ['dropCount', 'drop_count']),
      section: sectionVal,
      sectionRank: sectionRankVal,
      sectionLabel: sectionLabelVal,
      sectionColor: sectionColorVal,
      primarySectionColor: primarySectionColorVal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceZoneId': serviceZoneId,
      'userId': userId,
      'route_type': routeType,
      'delivery_type': deliveryType,
      'delivery_type_icon': deliveryTypeIcon,
      'delivery_type_id': deliveryTypeId,
      'pay_type': payType,
      'collect_time': collectTime,
      'scheduled_time': scheduledTime?.toIso8601String(),
      'vehicle_type_id': vehicleTypeId,
      'total_cost': totalCost,
      'total_fee': totalFee,
      'additional_cost': additionalCost,
      'commission': commission,
      'refund_amount': refundAmount,
      'has_additional_services': hasAdditionalServices,
      'is_promo_used': isPromoUsed,
      'notify_favorite_raider': notifyFavoriteRider,
      'payment_method_id': paymentMethodId,
      'compititor_id': competitorId,
      'competition_started_at': competitionStartedAt?.toIso8601String(),
      'competition_closed': competitionClosed,
      'assign_rider_id': assignRiderId,
      'assign_at': assignAt?.toIso8601String(),
      'collection_time': collectionTime,
      'collection_unit': collectionUnit,
      'raider_confirmation': raiderConfirmation,
      'is_auto_confirmation': isAutoConfirmation,
      'user_confirmation_at': userConfirmationAt?.toIso8601String(),
      'is_reviewed': isReviewed,
      'is_placed': isPlaced,
      'placed_at': placedAt?.toIso8601String(),
      'is_pickup': isPickup,
      'order_status': orderStatus,
      'is_out_for_delivery': isOutForDelivery,
      'isFixed': isFixed,
      'isDispute': isDispute,
      'isBulk': isBulk,
      'pick_up_items': pickUpItems,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user.toJson(),
      'vehicle': vehicle.toJson(),
      'orderStops': orderStops.map((stop) => stop.toJson()).toList(),
      'button_text': buttonText,
      'right_button_text': rightButtonText,
      'pricingSummary': pricingSummary,
      'distance_km': distanceKm,
      'total_raider_earnings': totalRaiderEarnings,
      'additional_service_fee': additionalServiceFee,
      'total_time': totalTime,
      'section': section,
      'sectionRank': sectionRank,
      'sectionLabel': sectionLabel,
      'sectionColor': sectionColor,
      'primarySectionColor': primarySectionColor,
    };
  }

  // Convenience getters
  String get pickupAddress {
    try {
      final pickup = orderStops.firstWhere((stop) => stop.isPickup);
      return pickup.displayName;
    } catch (e) {
      return 'Unknown location';
    }
  }

  List<String> get dropAddresses {
    return orderStops
        .where((stop) => stop.isDrop)
        .map((stop) => stop.displayName)
        .toList();
  }

  bool get isPending => orderStatus == 'PENDING';
  bool get isAccepted => orderStatus == 'ACCEPTED';
  bool get isInProgress => orderStatus == 'IN_PROGRESS';
  bool get isCompleted => orderStatus == 'COMPLETED';
  bool get isCancelled => orderStatus == 'CANCELLED';

  double get totalCostDouble {
    return double.tryParse(totalCost) ?? 0.0;
  }

  double get totalFeeDouble {
    return double.tryParse(totalFee) ?? 0.0;
  }

  double? get additionalCostDouble {
    if (additionalCost == null) {
      return null;
    }
    return double.tryParse(additionalCost!);
  }

  double get riderEarningDouble {
    return totalRaiderEarnings ?? totalCostDouble;
  }

  double? get additionalServiceFeeDouble {
    return additionalServiceFee;
  }

  double get effectiveDistanceKm {
    return distanceKm ?? 0.0;
  }

  double get extraCostDouble {
    final extraCost = totalCostDouble - riderEarningDouble;
    return extraCost < 0 ? 0.0 : extraCost;
  }

  double get displayBasePay {
    return basePay ?? riderEarningDouble;
  }

  double get displayExtraFee {
    return extraFee ?? extraCostDouble;
  }

  int get effectiveTotalTimeMinutes {
    if (totalTime != null && totalTime! > 0) {
      return totalTime!;
    }

    for (final stop in orderStops) {
      final rawData = stop.rawData;
      if (rawData == null) {
        continue;
      }

      final calculatedTime = _readNullableInt(rawData, [
        'calculated_time',
        'calculatedTime',
      ]);
      if (calculatedTime != null && calculatedTime > 0) {
        return calculatedTime;
      }
    }

    return 0;
  }

  int get effectiveCollectionTimeMinutes {
    final rawTime = collectionTime;
    if (rawTime == null || rawTime <= 0) {
      return 0;
    }

    switch ((collectionUnit ?? 'MINUTES').toUpperCase()) {
      case 'HOUR':
      case 'HOURS':
        return rawTime * 60;
      case 'DAY':
      case 'DAYS':
        return rawTime * 24 * 60;
      case 'SECOND':
      case 'SECONDS':
        return (rawTime / 60).ceil();
      case 'MINUTE':
      case 'MINUTES':
      default:
        return rawTime;
    }
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

  static bool _readBool(
    Map<String, dynamic> json,
    List<String> keys, {
    bool fallback = false,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) {
        return value;
      }
      if (value is String) {
        if (value.toLowerCase() == 'true') return true;
        if (value.toLowerCase() == 'false') return false;
      }
      if (value is num) {
        return value != 0;
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

  static Map<String, dynamic> _readMap(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }
    return <String, dynamic>{};
  }

  static double? _readNullableDouble(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }

  static String? _readDeliveryTypeIcon(Map<String, dynamic> json) {
    final feedMeta = _readMap(json, ['feedMeta']);
    final feedMetaIcon = _readNullableString(feedMeta, [
      'deliveryTypeIcon',
      'delivery_type_icon',
      'icon',
    ]);
    if (feedMetaIcon != null && feedMetaIcon.isNotEmpty) {
      return feedMetaIcon;
    }

    final deliveryTypeRaw = json['delivery_type'];
    if (deliveryTypeRaw is Map) {
      final icon = _readNullableString(
        Map<String, dynamic>.from(deliveryTypeRaw),
        ['icon', 'deliveryTypeIcon', 'delivery_type_icon'],
      );
      if (icon != null && icon.isNotEmpty) {
        return icon;
      }
    }

    return _readNullableString(json, [
      'deliveryTypeIcon',
      'delivery_type_icon',
      'icon',
    ]);
  }

  String? get deliveryTypeIconPath {
    return DeliveryTypeIconHelper.getDeliveryTypeIconPath(
      deliveryTypeIcon,
      deliveryType: deliveryType,
      deliveryTypeId: deliveryTypeId,
    );
  }

  static int _readDeliveryTypeId(Map<String, dynamic> json) {
    final directId = _readNullableInt(json, ['delivery_type_id', 'deliveryTypeId']);
    if (directId != null && directId > 0) return directId;

    final deliveryTypeRaw = json['delivery_type'];
    if (deliveryTypeRaw is Map) {
      final mapId = _readNullableInt(
        Map<String, dynamic>.from(deliveryTypeRaw),
        ['id', 'delivery_type_id', 'deliveryTypeId'],
      );
      if (mapId != null && mapId > 0) return mapId;
    }

    return 0;
  }

  static String _readDeliveryType(Map<String, dynamic> json) {
    final feedMeta = _readMap(json, ['feedMeta']);
    final feedMetaType = _readNullableString(feedMeta, ['deliveryType', 'delivery_type']);
    if (feedMetaType != null && feedMetaType.isNotEmpty) {
      return feedMetaType;
    }

    final deliveryType = _readNullableString(json, ['delivery_type']);
    if (deliveryType != null && deliveryType.isNotEmpty) {
      if (json['delivery_type'] is Map) {
        final deliveryTypeMap = Map<String, dynamic>.from(
          json['delivery_type'] as Map,
        );
        final name = _readNullableString(deliveryTypeMap, ['name']);
        if (name != null && name.isNotEmpty) {
          return name;
        }
      }
      return deliveryType;
    }

    if (json['delivery_type'] is Map) {
      final deliveryTypeMap = Map<String, dynamic>.from(
        json['delivery_type'] as Map,
      );
      final name = _readNullableString(deliveryTypeMap, ['name']);
      if (name != null && name.isNotEmpty) {
        return name;
      }
    }

    final deliveryTypeId = _readNullableInt(json, ['delivery_type_id']);
    switch (deliveryTypeId) {
      case 1:
        return 'EXPRESS';
      case 2:
        return 'SAVER';
      case 3:
        return 'STANDARD';
      default:
        return 'EXPRESS';
    }
  }

  static int? _readDeliveryTypeCollectionTime(Map<String, dynamic> json) {
    final deliveryTypeRaw = json['delivery_type'];
    if (deliveryTypeRaw is Map) {
      return _readNullableInt(Map<String, dynamic>.from(deliveryTypeRaw), [
        'collection_time',
        'collectionTime',
      ]);
    }

    return _readNullableInt(json, ['collection_time', 'collectionTime']);
  }

  static String? _readDeliveryTypeCollectionUnit(Map<String, dynamic> json) {
    final deliveryTypeRaw = json['delivery_type'];
    if (deliveryTypeRaw is Map) {
      return _readNullableString(Map<String, dynamic>.from(deliveryTypeRaw), [
        'collection_unit',
        'collectionUnit',
      ]);
    }

    return _readNullableString(json, ['collection_unit', 'collectionUnit']);
  }

  static Map<String, dynamic> _resolveVehicleJson(Map<String, dynamic> json) {
    if (json['vehicle'] is Map) {
      return Map<String, dynamic>.from(json['vehicle'] as Map);
    }

    final deliveryTypeRaw = json['delivery_type'];
    if (deliveryTypeRaw is! Map) {
      return <String, dynamic>{};
    }

    final deliveryType = Map<String, dynamic>.from(deliveryTypeRaw);
    final vehicleTypes = deliveryType['vehicle_types'];
    if (vehicleTypes is! List) {
      return <String, dynamic>{};
    }

    final targetVehicleTypeId = _readNullableInt(json, ['vehicle_type_id']);
    for (final item in vehicleTypes) {
      if (item is! Map) {
        continue;
      }

      final vehicleTypeEntry = Map<String, dynamic>.from(item);
      final vehicleTypeId = _readNullableInt(vehicleTypeEntry, [
        'vehicle_type_id',
      ]);
      final vehicle = vehicleTypeEntry['vehicle_type'];
      if (vehicle is Map &&
          (targetVehicleTypeId == null ||
              vehicleTypeId == targetVehicleTypeId)) {
        return Map<String, dynamic>.from(vehicle);
      }
    }

    for (final item in vehicleTypes) {
      if (item is! Map) {
        continue;
      }
      final vehicle = item['vehicle_type'];
      if (vehicle is Map) {
        return Map<String, dynamic>.from(vehicle);
      }
    }

    return <String, dynamic>{};
  }
}
