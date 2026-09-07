// API Response Models
class OrderFeedResponse {
  final bool success;
  final String message;
  final OrderFeedData data;

  OrderFeedResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory OrderFeedResponse.fromJson(Map<String, dynamic> json) {
    return OrderFeedResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: OrderFeedData.fromJson(json['data'] ?? {}),
    );
  }
}

class OrderFeedData {
  final List<Order> orders;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  OrderFeedData({
    required this.orders,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory OrderFeedData.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List? ?? [];
    return OrderFeedData(
      orders: dataList.map((item) => Order.fromJson(item)).toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class Order {
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
  final String? placedAt;
  final User user;
  final Vehicle vehicle;
  final List<Destination> destinations;

  Order({
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
    required this.user,
    required this.vehicle,
    required this.destinations,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var destList = json['destinations'] as List? ?? [];
    return Order(
      id: json['id'] ?? 0,
      routeType: json['route_type'] ?? 'ONE_WAY',
      deliveryType: json['delivery_type'] ?? 'EXPRESS',
      payType: json['pay_type'] ?? 'COD',
      collectTime: json['collect_time'] ?? 'ASAP',
      scheduledTime: json['scheduled_time'],
      vehicleTypeId: json['vehicle_type_id'] ?? 0,
      totalCost: _parseToString(json['total_cost']),
      orderStatus: json['order_status'] ?? 'PENDING',
      isPlaced: json['is_placed'] ?? false,
      placedAt: json['placed_at'],
      user: User.fromJson(json['user'] ?? {}),
      vehicle: Vehicle.fromJson(json['vehicle'] ?? {}),
      destinations: destList.map((item) => Destination.fromJson(item)).toList(),
    );
  }
}

class User {
  final int id;
  final String username;
  final String email;
  final String phone;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
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
      id: json['id'] ?? 0,
      vehicleType: json['vehicle_type'] ?? 'SUV',
      basePrice: _parseToString(json['base_price']),
      perKmPrice: _parseToString(json['per_km_price']),
      dimension: json['dimension'] ?? '',
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
  final String latitude;
  final String longitude;

  Destination({
    required this.id,
    required this.address,
    required this.type,
    required this.contactName,
    required this.contactNumber,
    this.noteToDriver,
    required this.latitude,
    required this.longitude,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] ?? 0,
      address: json['address'] ?? '',
      type: json['type'] ?? 'RECEIVER',
      contactName: json['contact_name'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      noteToDriver: json['note_to_driver'],
      latitude: _parseToString(json['latitude']),
      longitude: _parseToString(json['longitude']),
    );
  }
}

// Helper function to convert any type to String
String _parseToString(dynamic value) {
  if (value == null) return '0';
  if (value is String) return value;
  if (value is int) return value.toString();
  if (value is double) return value.toString();
  return value.toString();
}
