class OrderStopModel {
  final int id;
  final int orderId;
  final int destinationId;
  final Map<String, dynamic>? rawData;
  final String address;
  final String shortName;
  final String destinationAddressFromApr;
  final String destinationContactName;
  final String destinationContactNumber;
  final String destinationFloorUnit;
  final String? destinationNoteToDriver;
  final double latitude;
  final double longitude;
  final String? additionalInfo;
  final String type; // PICKUP or DROP
  final int sequence;
  final String status; // PENDING, COMPLETED, FAILED
  final bool proceedToPickup;
  final bool isArrived;
  final bool isLoad;
  final bool isUnload;
  final bool isSkiped;
  final String calculatedPrice;
  final String calculatedDistance;
  final int? calculatedTime;
  final String? calculatedTimeTxt;
  final List<dynamic> proofs;
  final String? notes;
  final DateTime? arrivedAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final String? failureReason;
  final OrderStopPayment? payment;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderStopModel({
    required this.id,
    required this.orderId,
    required this.destinationId,
    this.rawData,
    required this.address,
    this.shortName = '',
    this.destinationAddressFromApr = '',
    this.destinationContactName = '',
    this.destinationContactNumber = '',
    this.destinationFloorUnit = '',
    this.destinationNoteToDriver,
    required this.latitude,
    required this.longitude,
    this.additionalInfo,
    required this.type,
    required this.sequence,
    required this.status,
    required this.proceedToPickup,
    required this.isArrived,
    required this.isLoad,
    required this.isUnload,
    required this.isSkiped,
    this.calculatedPrice = '0',
    this.calculatedDistance = '0',
    this.calculatedTime,
    this.calculatedTimeTxt,
    required this.proofs,
    this.notes,
    this.arrivedAt,
    this.completedAt,
    this.failedAt,
    this.failureReason,
    this.payment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderStopModel.fromJson(Map<String, dynamic> json) {
    final destination = json['destination'] is Map
        ? Map<String, dynamic>.from(json['destination'] as Map)
        : <String, dynamic>{};
    final payment = json['payment'] is Map
        ? Map<String, dynamic>.from(json['payment'] as Map)
        : <String, dynamic>{};

    return OrderStopModel(
      id: _readInt(json, ['id']),
      orderId: _readInt(json, ['orderId', 'order_id']),
      destinationId: _readInt(json, ['destinationId', 'destination_id']),
      rawData: Map<String, dynamic>.from(json),
      address: _readString(json, ['address']),
      shortName: _readString(destination, [
        'shortName',
        'short_name',
      ], fallback: _readString(json, ['shortName', 'short_name'])),
      destinationAddressFromApr: _readString(destination, [
        'addressFromApr',
        'address_from_apr',
      ], fallback: _readString(json, ['address'])),
      destinationContactName: _readString(destination, ['contact_name']),
      destinationContactNumber: _readString(destination, ['contact_number']),
      destinationFloorUnit: _readString(destination, ['floor_unit']),
      destinationNoteToDriver: _readNullableString(destination, [
        'note_to_driver',
      ]),
      latitude: _readDouble(json, ['latitude']),
      longitude: _readDouble(json, ['longitude']),
      additionalInfo: _readNullableString(json, [
        'additionalInfo',
        'note_to_driver',
      ]),
      type: _normalizeStopType(_readString(json, ['type'], fallback: 'DROP')),
      sequence: _readInt(json, ['sequence'], fallback: 0),
      status: _readString(json, ['status'], fallback: 'PENDING'),
      proceedToPickup: _readBool(json, ['proceed_to_pickup']),
      isArrived: _readBool(json, ['is_arrived']),
      isLoad: _readBool(json, ['is_load']),
      isUnload: _readBool(json, ['is_unload']),
      isSkiped: _readBool(json, ['is_skiped']),
      calculatedPrice: _readString(json, ['calculated_price'], fallback: '0'),
      calculatedDistance: _readString(json, [
        'calculated_distance',
      ], fallback: '0'),
      calculatedTime: _readNullableInt(json, ['calculated_time']),
      calculatedTimeTxt: _readNullableString(json, ['calculated_time_txt']),
      proofs: json['proofs'] as List? ?? [],
      notes: _readNullableString(json, ['notes']),
      arrivedAt: _readDateTime(json, ['arrivedAt', 'arrived_at']),
      completedAt: _readDateTime(json, ['completedAt', 'completed_at']),
      failedAt: _readDateTime(json, ['failedAt', 'failed_at']),
      failureReason: _readNullableString(json, [
        'failureReason',
        'failure_reason',
      ]),
      payment: payment.isNotEmpty ? OrderStopPayment.fromJson(payment) : null,
      createdAt:
          _readDateTime(json, ['createdAt', 'created_at']) ?? DateTime.now(),
      updatedAt:
          _readDateTime(json, ['updatedAt', 'updated_at']) ?? DateTime.now(),
    );
  }

  factory OrderStopModel.fromDestinationJson(
    Map<String, dynamic> json, {
    required int orderId,
    required int index,
  }) {
    final rawType = _readString(json, ['type'], fallback: '');

    return OrderStopModel(
      id: _readInt(json, ['id']),
      orderId: orderId,
      destinationId: _readInt(json, ['destinationId', 'destination_id', 'id']),
      rawData: {
        ...Map<String, dynamic>.from(json),
        'orderId': orderId,
        'destinationId': _readInt(json, [
          'destinationId',
          'destination_id',
          'id',
        ]),
        'type': rawType.isEmpty ? (index == 0 ? 'PICKUP' : 'DROP') : rawType,
        'sequence': _readInt(json, ['sequence'], fallback: index + 1),
        'destination': Map<String, dynamic>.from(json),
      },
      address: _readString(json, ['address']),
      shortName: _readString(json, ['shortName', 'short_name']),
      destinationAddressFromApr: _readString(json, [
        'addressFromApr',
        'address_from_apr',
      ], fallback: _readString(json, ['address'])),
      destinationContactName: _readString(json, ['contact_name']),
      destinationContactNumber: _readString(json, ['contact_number']),
      destinationFloorUnit: _readString(json, ['floor_unit']),
      destinationNoteToDriver: _readNullableString(json, ['note_to_driver']),
      latitude: _readDouble(json, ['latitude']),
      longitude: _readDouble(json, ['longitude']),
      additionalInfo: _readNullableString(json, [
        'note_to_driver',
        'additionalInfo',
      ]),
      type: rawType.isEmpty
          ? (index == 0 ? 'PICKUP' : 'DROP')
          : _normalizeStopType(
              rawType,
              fallback: index == 0 ? 'PICKUP' : 'DROP',
            ),
      sequence: _readInt(json, ['sequence'], fallback: index + 1),
      status: _readString(json, ['status'], fallback: 'PENDING'),
      proceedToPickup: _readBool(json, ['proceed_to_pickup']),
      isArrived: _readBool(json, ['is_arrived']),
      isLoad: _readBool(json, ['is_load']),
      isUnload: _readBool(json, ['is_unload']),
      isSkiped: _readBool(json, ['is_skiped']),
      calculatedPrice: _readString(json, ['calculated_price'], fallback: '0'),
      calculatedDistance: _readString(json, [
        'calculated_distance',
      ], fallback: '0'),
      calculatedTime: _readNullableInt(json, ['calculated_time']),
      calculatedTimeTxt: _readNullableString(json, ['calculated_time_txt']),
      proofs: json['proofs'] as List? ?? [],
      notes: _readNullableString(json, ['notes', 'note_to_driver']),
      arrivedAt: _readDateTime(json, ['arrivedAt', 'arrived_at']),
      completedAt: _readDateTime(json, ['completedAt', 'completed_at']),
      failedAt: _readDateTime(json, ['failedAt', 'failed_at']),
      failureReason: _readNullableString(json, [
        'failureReason',
        'failure_reason',
      ]),
      payment: null,
      createdAt:
          _readDateTime(json, ['createdAt', 'created_at']) ?? DateTime.now(),
      updatedAt:
          _readDateTime(json, ['updatedAt', 'updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    if (rawData != null) {
      return Map<String, dynamic>.from(rawData!);
    }

    return {
      'id': id,
      'orderId': orderId,
      'destinationId': destinationId,
      'address': address,
      'shortName': shortName,
      'destinationAddressFromApr': destinationAddressFromApr,
      'destinationContactName': destinationContactName,
      'destinationContactNumber': destinationContactNumber,
      'destinationFloorUnit': destinationFloorUnit,
      'destinationNoteToDriver': destinationNoteToDriver,
      'latitude': latitude,
      'longitude': longitude,
      'additionalInfo': additionalInfo,
      'type': type,
      'sequence': sequence,
      'status': status,
      'proceed_to_pickup': proceedToPickup,
      'is_arrived': isArrived,
      'is_load': isLoad,
      'is_unload': isUnload,
      'is_skiped': isSkiped,
      'calculated_price': calculatedPrice,
      'calculated_distance': calculatedDistance,
      'calculated_time': calculatedTime,
      'calculated_time_txt': calculatedTimeTxt,
      'proofs': proofs,
      'notes': notes,
      'arrivedAt': arrivedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'failedAt': failedAt?.toIso8601String(),
      'failureReason': failureReason,
      'payment': payment?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isPickup => type == 'PICKUP';
  bool get isDrop => type == 'DROP';
  String get displayName {
    final trimmedShortName = shortName.trim();
    if (trimmedShortName.isNotEmpty) {
      return trimmedShortName;
    }

    final destination = rawData?['destination'];
    if (destination is Map) {
      final destinationShortName = _readString(
        Map<String, dynamic>.from(destination),
        ['shortName', 'short_name'],
      ).trim();
      if (destinationShortName.isNotEmpty) {
        return destinationShortName;
      }
    }

    return address;
  }

  bool get isPending => status == 'PENDING';
  bool get isCompleted => status == 'COMPLETED';
  bool get isFailed => status == 'FAILED';
  double get calculatedDistanceDouble =>
      double.tryParse(calculatedDistance) ?? 0.0;

  static String _normalizeStopType(String value, {String fallback = 'DROP'}) {
    final normalized = value.toUpperCase();
    if (normalized == 'PICKUP' || normalized == 'SENDER') {
      return 'PICKUP';
    }
    if (normalized == 'DROP' || normalized == 'RECEIVER') {
      return 'DROP';
    }
    return fallback;
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
        final parsed = int.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }

  static double _readDouble(
    Map<String, dynamic> json,
    List<String> keys, {
    double fallback = 0,
  }) {
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
}

class OrderStopPayment {
  final int id;
  final int orderStopId;
  final String payType;
  final String amount;
  final String status;
  final String discount;
  final DateTime? collectedAt;
  final String? collectedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderStopPayment({
    required this.id,
    required this.orderStopId,
    required this.payType,
    required this.amount,
    required this.status,
    required this.discount,
    this.collectedAt,
    this.collectedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderStopPayment.fromJson(Map<String, dynamic> json) {
    return OrderStopPayment(
      id: OrderStopModel._readInt(json, ['id']),
      orderStopId: OrderStopModel._readInt(json, [
        'orderStopId',
        'order_stop_id',
      ]),
      payType: OrderStopModel._readString(json, ['payType', 'pay_type']),
      amount: OrderStopModel._readString(json, ['amount'], fallback: '0'),
      status: OrderStopModel._readString(json, ['status'], fallback: 'UNPAID'),
      discount: OrderStopModel._readString(json, ['discount'], fallback: '0'),
      collectedAt: OrderStopModel._readDateTime(json, [
        'collectedAt',
        'collected_at',
      ]),
      collectedBy: OrderStopModel._readNullableString(json, [
        'collectedBy',
        'collected_by',
      ]),
      createdAt: OrderStopModel._readDateTime(json, [
        'createdAt',
        'created_at',
      ]),
      updatedAt: OrderStopModel._readDateTime(json, [
        'updatedAt',
        'updated_at',
      ]),
    );
  }

  double get amountDouble => double.tryParse(amount) ?? 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderStopId': orderStopId,
      'payType': payType,
      'amount': amount,
      'status': status,
      'discount': discount,
      'collectedAt': collectedAt?.toIso8601String(),
      'collectedBy': collectedBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
