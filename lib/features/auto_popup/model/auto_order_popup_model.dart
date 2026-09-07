import 'package:ZipBee_Driver/core/utils/delivery_type_icon_helper.dart';

class AutoOrderPopupModel {
  final int orderId;
  final String? popupId;
  final int timeoutSeconds;
  final String vehicleType;
  final String deliveryType;
  final String? deliveryTypeIcon;
  final String payType;
  final double riderEarning;
  final double additionalFee;
  final double distanceKm;
  final String estimatedTimeText;
  final String pickupAddress;
  final String dropAddress;
  final String comment;
  final Map<String, dynamic> rawPayload;
  final Map<String, dynamic>? rawOrder;
  final double? raiderToPickupKm;
  final double? basePay;
  final double? extraFee;
  final int? dropCount;

  AutoOrderPopupModel({
    required this.orderId,
    required this.popupId,
    required this.timeoutSeconds,
    required this.vehicleType,
    required this.deliveryType,
    this.deliveryTypeIcon,
    required this.payType,
    required this.riderEarning,
    required this.additionalFee,
    required this.distanceKm,
    required this.estimatedTimeText,
    required this.pickupAddress,
    required this.dropAddress,
    required this.comment,
    required this.rawPayload,
    required this.rawOrder,
    this.raiderToPickupKm,
    this.basePay,
    this.extraFee,
    this.dropCount,
  });

  String? get deliveryTypeIconPath =>
      DeliveryTypeIconHelper.getDeliveryTypeIconPath(
        deliveryTypeIcon,
        deliveryType: deliveryType,
      );

  factory AutoOrderPopupModel.fromSocket(dynamic payload) {
    final root = _asMap(payload);
    final order = _asMap(root['order'] ?? root['data'] ?? root['orderData']);
    final source = order.isNotEmpty ? order : root;
    final pricing = _asMap(source['pricingSummary']);
    final stops = _asList(source['orderStops'] ?? source['stops'] ?? root['orderStops'] ?? root['stops']);
    final destinations = _asList(source['destinations'] ?? root['destinations']);

    final pickup =
        _firstStopAddress(stops, isPickup: true) ??
        _firstStopAddress(destinations, isPickup: true) ??
        _readString(source, ['pickupAddress', 'pickup_address']) ??
        _readString(root, ['pickupAddress', 'pickup_address']) ??
        'Pickup location';
    final drop =
        _lastStopAddress(stops, isPickup: false) ??
        _lastStopAddress(destinations, isPickup: false) ??
        _readString(source, ['dropAddress', 'drop_address', 'destination']) ??
        _readString(root, ['dropAddress', 'drop_address', 'destination']) ??
        'Drop location';

    final feedMeta = _asMap(source['feedMeta'] ?? root['feedMeta']);
    final raiderToPickupKm = _readDouble(root, ['distanceKm', 'distance_km']) ??
        _readDouble(feedMeta, ['raiderToPickupKm']);
    final basePay = _readDouble(feedMeta, ['basePay', 'base_pay']) ??
        _readDouble(source, ['basePay', 'base_pay', 'totalCost', 'total_cost']) ??
        _readDouble(root, ['basePay', 'base_pay', 'totalCost']);
    final extraFee = _readDouble(feedMeta, ['extraFee', 'extra_fee']) ??
        _readDouble(source, ['extraFee', 'extra_fee']) ??
        _readDouble(root, ['extraFee', 'extra_fee']);
    final dropCount = _readInt(feedMeta, ['dropCount']);
    final deliveryTypeIcon =
        _readString(feedMeta, ['deliveryTypeIcon', 'delivery_type_icon', 'icon']) ??
        _readString(_asMap(source['delivery_type']), ['icon', 'deliveryTypeIcon']) ??
        _readString(source, ['deliveryTypeIcon', 'delivery_type_icon', 'icon']);

    return AutoOrderPopupModel(
      orderId:
          _readInt(root, ['orderId', 'order_id', 'id']) ??
          _readInt(source, ['id', 'orderId', 'order_id']) ??
          0,
      popupId: _readString(root, ['popupId', 'popup_id', 'id']),
      timeoutSeconds:
          _readInt(root, [
            'timeoutSeconds',
            'timeout',
            'expiresIn',
            'timeRemaining',
            'seconds',
          ]) ??
          _readInt(source, ['timeoutSeconds', 'timeout']) ??
          15,
      vehicleType:
          _readString(source, ['vehicleType', 'vehicle_type']) ??
          _readString(root, ['vehicleType', 'vehicle_type']) ??
          _readString(_asMap(source['vehicle']), ['vehicleType', 'name']) ??
          'Car',
      deliveryType:
          _readString(source, ['deliveryType', 'delivery_type']) ??
          _readString(root, ['deliveryType', 'delivery_type']) ??
          'EXPRESS',
      deliveryTypeIcon: deliveryTypeIcon,
      payType: _readString(source, ['payType', 'pay_type']) ?? 'COD',
      riderEarning:
          _readDouble(source, ['totalCost', 'total_cost', 'riderEarning']) ??
          _readDouble(pricing, ['totalRaiderEarnings']) ??
          _readDouble(root, ['totalCost', 'riderEarning']) ??
          0,
      additionalFee:
          _readDouble(pricing, ['additionServiceFee']) ??
          _readDouble(source, ['additionalServiceFee', 'additional_cost']) ??
          0,
      distanceKm:
          _readDouble(root, ['distanceKm', 'distance_km']) ??
          _readDouble(source, ['totalDistance', 'distanceKm', 'distance_km']) ??
          _readDouble(pricing, ['totalDistance']) ??
          0,
      estimatedTimeText:
          _readString(source, ['estimatedTimeText', 'estimated_time_text']) ??
          _estimatedTime(source),
      pickupAddress: pickup,
      dropAddress: drop,
      comment:
          _readString(root, ['message']) ??
          _readString(source, ['comment', 'remarks', 'note', 'notes']) ??
          'New order available!',
      rawPayload: root,
      rawOrder: order.isEmpty ? null : order,
      raiderToPickupKm: raiderToPickupKm,
      basePay: basePay,
      extraFee: extraFee,
      dropCount: dropCount,
    );
  }

  int get displayDropCount {
    if (dropCount != null) return dropCount!;
    final stopsList = _asList(rawPayload['orderStops'] ?? rawPayload['stops'] ?? (rawOrder != null ? (rawOrder!['orderStops'] ?? rawOrder!['stops']) : null));
    final destList = _asList(rawPayload['destinations'] ?? (rawOrder != null ? rawOrder!['destinations'] : null));
    final list = stopsList.isNotEmpty ? stopsList : destList;
    int count = 0;
    for (final s in list) {
      final map = _asMap(s);
      final type = (_readString(map, ['type', 'stop_type']) ?? '').toUpperCase();
      final sequence = _readInt(map, ['sequence']) ?? 0;
      if (type.contains('DROP') || type.contains('RECEIVER') || sequence > 1) {
        count++;
      }
    }
    return count > 0 ? count : 1;
  }

  double get displayBasePay {
    return basePay ?? riderEarning;
  }

  double get displayExtraFee {
    return extraFee ?? additionalFee;
  }

  String get routeType {
    final root = rawPayload;
    final order = rawOrder ?? {};
    final source = order.isNotEmpty ? order : root;
    return _readString(source, ['routeType', 'route_type']) ?? '';
  }

  bool get isRoundTrip => routeType.toUpperCase() == 'ROUND';

  int get displayStopsCount {
    final count = displayDropCount;
    if (isRoundTrip) return count;
    return count > 1 ? count - 1 : 0;
  }

  String get finalDropAddress {
    if (isRoundTrip) return pickupAddress;
    return dropAddress;
  }

  Map<String, dynamic> get ackPayload {
    return {
      'orderId': orderId,
      if (popupId != null && popupId!.isNotEmpty) 'popupId': popupId,
    };
  }

  String get earningText => '\$${riderEarning.toStringAsFixed(2)}';

  String get additionalFeeText => '+\$${additionalFee.toStringAsFixed(2)}';

  String get distanceText => '${distanceKm.toStringAsFixed(1)}Km';

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static List<dynamic> _asList(dynamic value) {
    if (value is List) return value;
    return const [];
  }

  static String? _firstStopAddress(
    List<dynamic> stops, {
    required bool isPickup,
  }) {
    for (final stop in stops) {
      final map = _asMap(stop);
      if (map.isEmpty) continue;
      final type = (_readString(map, ['type', 'stop_type']) ?? '')
          .toUpperCase();
      final sequence = _readInt(map, ['sequence']);
      final matchesPickup = type.contains('PICK') || sequence == 1;
      if (matchesPickup != isPickup) continue;

      // 1. Try shortName from stop itself
      var shortName = _readString(map, ['shortName', 'short_name']);
      if (shortName != null && shortName.trim().isNotEmpty) {
        return shortName.trim();
      }

      // 2. Try shortName from destination
      final destination = _asMap(map['destination']);
      if (destination.isNotEmpty) {
        shortName = _readString(destination, ['shortName', 'short_name']);
        if (shortName != null && shortName.trim().isNotEmpty) {
          return shortName.trim();
        }
      }

      // 3. Fallback to address
      final address = _readString(map, [
        'address',
        'destinationAddress',
        'destination_address',
        'destinationAddressFromApr',
      ]);
      if (address != null && address.trim().isNotEmpty) return address.trim();
    }
    return null;
  }

  static String? _lastStopAddress(
    List<dynamic> stops, {
    required bool isPickup,
  }) {
    dynamic targetStop;
    int maxSeq = -1;
    for (final stop in stops) {
      final map = _asMap(stop);
      if (map.isEmpty) continue;
      final type = (_readString(map, ['type', 'stop_type']) ?? '')
          .toUpperCase();
      final sequence = _readInt(map, ['sequence']) ?? 0;
      final matchesPickup = type.contains('PICK') || sequence == 1;
      if (matchesPickup != isPickup) continue;

      if (sequence >= maxSeq) {
        maxSeq = sequence;
        targetStop = map;
      }
    }

    if (targetStop != null) {
      final map = _asMap(targetStop);
      // 1. Try shortName from stop itself
      var shortName = _readString(map, ['shortName', 'short_name']);
      if (shortName != null && shortName.trim().isNotEmpty) {
        return shortName.trim();
      }

      // 2. Try shortName from destination
      final destination = _asMap(map['destination']);
      if (destination.isNotEmpty) {
        shortName = _readString(destination, ['shortName', 'short_name']);
        if (shortName != null && shortName.trim().isNotEmpty) {
          return shortName.trim();
        }
      }

      // 3. Fallback to address
      final address = _readString(map, [
        'address',
        'destinationAddress',
        'destination_address',
        'destinationAddressFromApr',
      ]);
      if (address != null && address.trim().isNotEmpty) return address.trim();
    }
    return null;
  }

  static String _estimatedTime(Map<String, dynamic> source) {
    final minutes = _readInt(source, [
      'estimatedTimeMinutes',
      'estimated_time_minutes',
      'durationMinutes',
    ]);
    if (minutes == null || minutes <= 0) return '5 Mins';
    return '$minutes Mins';
  }

  static String? _readString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) continue;
      final text = value.toString();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  static int? _readInt(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static double? _readDouble(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }
}
