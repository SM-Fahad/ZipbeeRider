// Order Detail Response Models
class OrderDetailResponse {
  final bool success;
  final String message;
  final OrderDetail data;
  final Map<String, dynamic> rawData;

  OrderDetailResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.rawData,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : <String, dynamic>{};

    return OrderDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: OrderDetail.fromJson(rawData),
      rawData: rawData,
    );
  }
}

class OrderDetail {
  final int id;
  final String routeType;
  final String deliveryType;
  final String payType;
  final String collectTime;
  final String? scheduledTime;
  final int vehicleTypeId;
  final String totalCost;
  final String orderStatus;
  final bool isPlaced;
  final DateTime? placedAt;
  final bool isPickup;
  final String? noteToDriver;
  final List<String> pickupItems;
  final User user;
  final Vehicle vehicle;
  final List<Destination> destinations;

  OrderDetail({
    required this.id,
    required this.routeType,
    required this.deliveryType,
    required this.payType,
    required this.collectTime,
    this.scheduledTime,
    required this.vehicleTypeId,
    required this.totalCost,
    required this.orderStatus,
    required this.isPlaced,
    this.placedAt,
    required this.isPickup,
    this.noteToDriver,
    required this.pickupItems,
    required this.user,
    required this.vehicle,
    required this.destinations,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    final destList = _extractDestinations(json);
    final itemsList = (json['pick_up_items'] as List? ?? [])
        .map((item) => item.toString())
        .toList();
    final deliveryTypeMap = json['delivery_type'] is Map
        ? Map<String, dynamic>.from(json['delivery_type'] as Map)
        : <String, dynamic>{};

    return OrderDetail(
      id: _readInt(json, ['id']),
      routeType: _readString(json, ['route_type'], fallback: 'ONE_WAY'),
      deliveryType: _readDeliveryType(json, deliveryTypeMap),
      payType: _readString(json, ['pay_type'], fallback: 'COD'),
      collectTime: _readString(json, ['collect_time'], fallback: 'ASAP'),
      scheduledTime: _readNullableString(json, ['scheduled_time']),
      vehicleTypeId: _readInt(json, ['vehicle_type_id']),
      totalCost: _parseToString(json['total_cost']),
      orderStatus: _readString(json, ['order_status'], fallback: 'PENDING'),
      isPlaced: _readBool(json, ['is_placed']),
      placedAt: _readDateTime(json, ['placed_at', 'placedAt']),
      isPickup: _readBool(json, ['is_pickup']),
      noteToDriver: _readNullableString(json, ['note_to_driver']),
      pickupItems: itemsList,
      user: User.fromJson(
        json['user'] is Map ? Map<String, dynamic>.from(json['user'] as Map) : {},
      ),
      vehicle: Vehicle.fromJson(_resolveVehicleJson(json, deliveryTypeMap)),
      destinations: destList.map(Destination.fromJson).toList(),
    );
  }

  // Get sender destination
  Destination? getSenderDestination() {
    try {
      return destinations.firstWhere((dest) => dest.type == 'SENDER');
    } catch (e) {
      return null;
    }
  }

  // Get receiver destination
  Destination? getReceiverDestination() {
    try {
      return destinations.firstWhere((dest) => dest.type == 'RECEIVER');
    } catch (e) {
      return null;
    }
  }
}

class User {
  final int id;
  final String username;
  final String email;
  final String phone;
  final String? image;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'],
    );
  }
}

class Vehicle {
  final int id;
  final String vehicleType;
  final String basePrice;
  final String perKmPrice;
  final String dimension;
  final String maxLoad;

  Vehicle({
    required this.id,
    required this.vehicleType,
    required this.basePrice,
    required this.perKmPrice,
    required this.dimension,
    required this.maxLoad,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: _readInt(json, ['id']),
      vehicleType: _readString(
        json,
        ['vehicle_type', 'vehicleType', 'vehicle_name'],
        fallback: 'SUV',
      ),
      basePrice: _parseToString(json['base_price']),
      perKmPrice: _parseToString(json['per_km_price']),
      dimension: _readString(
        json,
        ['dimension'],
        fallback:
            '${_parseToString(json['dimension_width'])} x ${_parseToString(json['dimension_height'])} x ${_parseToString(json['dimension_length'])}',
      ),
      maxLoad: _parseToString(json['max_load']),
    );
  }
}

class Destination {
  final int id;
  final String address;
  final String type;
  final String contactName;
  final String contactNumber;
  final String? noteToDriver;
  final String floorUnit;
  final String latitude;
  final String longitude;

  Destination({
    required this.id,
    required this.address,
    required this.type,
    required this.contactName,
    required this.contactNumber,
    this.noteToDriver,
    required this.floorUnit,
    required this.latitude,
    required this.longitude,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: _readInt(json, ['id']),
      address: _readString(json, ['address']),
      type: _readString(json, ['type'], fallback: 'RECEIVER'),
      contactName: _readString(json, ['contact_name']),
      contactNumber: _readString(json, ['contact_number']),
      noteToDriver: _readNullableString(json, ['note_to_driver']),
      floorUnit: _readString(json, ['floor_unit']),
      latitude: _parseToString(json['latitude']),
      longitude: _parseToString(json['longitude']),
    );
  }
}

List<Map<String, dynamic>> _extractDestinations(Map<String, dynamic> json) {
  final destinations = json['destinations'];
  if (destinations is List) {
    return destinations
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  final orderStops = json['orderStops'];
  if (orderStops is List) {
    return orderStops
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map((stop) {
          final destination = stop['destination'];
          if (destination is Map) {
            return Map<String, dynamic>.from(destination);
          }
          return <String, dynamic>{
            'id': stop['destinationId'] ?? stop['destination_id'],
            'address': stop['address'],
            'type': stop['type'] == 'PICKUP' ? 'SENDER' : 'RECEIVER',
            'latitude': stop['latitude'],
            'longitude': stop['longitude'],
          };
        })
        .toList();
  }

  return <Map<String, dynamic>>[];
}

Map<String, dynamic> _resolveVehicleJson(
  Map<String, dynamic> json,
  Map<String, dynamic> deliveryTypeMap,
) {
  if (json['vehicle'] is Map) {
    return Map<String, dynamic>.from(json['vehicle'] as Map);
  }

  final vehicleTypes = deliveryTypeMap['vehicle_types'];
  if (vehicleTypes is! List) {
    return <String, dynamic>{};
  }

  final targetVehicleTypeId = _readInt(json, ['vehicle_type_id']);
  for (final item in vehicleTypes) {
    if (item is! Map) continue;
    final entry = Map<String, dynamic>.from(item);
    final vehicle = entry['vehicle_type'];
    final vehicleTypeId = _readInt(entry, ['vehicle_type_id'], fallback: -1);
    if (vehicle is Map && vehicleTypeId == targetVehicleTypeId) {
      return Map<String, dynamic>.from(vehicle);
    }
  }

  for (final item in vehicleTypes) {
    if (item is! Map) continue;
    final vehicle = item['vehicle_type'];
    if (vehicle is Map) {
      return Map<String, dynamic>.from(vehicle);
    }
  }

  return <String, dynamic>{};
}

String _readDeliveryType(
  Map<String, dynamic> json,
  Map<String, dynamic> deliveryTypeMap,
) {
  final direct = json['delivery_type'];
  if (direct is String && direct.isNotEmpty) {
    return direct;
  }

  final nestedName = _readNullableString(deliveryTypeMap, ['name']);
  if (nestedName != null && nestedName.isNotEmpty) {
    return nestedName;
  }

  return 'EXPRESS';
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is String) return value;
    if (value != null && value is! Map && value is! List) {
      return value.toString();
    }
  }
  return fallback;
}

String? _readNullableString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is String) return value;
    if (value is! Map && value is! List) {
      return value.toString();
    }
  }
  return null;
}

DateTime? _readDateTime(Map<String, dynamic> json, List<String> keys) {
  final str = _readNullableString(json, keys);
  if (str == null || str.isEmpty) return null;
  return DateTime.tryParse(str);
}

int _readInt(Map<String, dynamic> json, List<String> keys, {int fallback = 0}) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return fallback;
}

bool _readBool(
  Map<String, dynamic> json,
  List<String> keys, {
  bool fallback = false,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    if (value is num) return value != 0;
  }
  return fallback;
}

// Helper function to convert any type to String
String _parseToString(dynamic value) {
  if (value == null) return '0';
  if (value is String) return value;
  if (value is int) return value.toString();
  if (value is double) return value.toString();
  return value.toString();
}
