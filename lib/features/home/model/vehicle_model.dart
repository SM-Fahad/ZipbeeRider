class VehicleModel {
  final int id;
  final String vehicleType;
  final String vehicleName;
  final String basePrice;
  final String perKmPrice;
  final bool peakPricing;
  final String dimension;
  final String maxLoad;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleModel({
    required this.id,
    required this.vehicleType,
    required this.vehicleName,
    required this.basePrice,
    required this.perKmPrice,
    required this.peakPricing,
    required this.dimension,
    required this.maxLoad,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: _readInt(json, ['id']),
      vehicleType: _readString(json, [
        'vehicle_type',
        'vehicleType',
      ], fallback: 'UNKNOWN'),
      vehicleName: _readString(json, [
        'vehicle_name',
        'vehicleName',
      ], fallback: ''),
      basePrice: _readString(json, ['base_price', 'basePrice'], fallback: '0'),
      perKmPrice: _readString(json, [
        'per_km_price',
        'perKmPrice',
      ], fallback: '0'),
      peakPricing: json['peak_pricing'] as bool? ?? false,
      dimension: _readString(json, ['dimension']),
      maxLoad: _readString(json, ['max_load', 'maxLoad'], fallback: '0'),
      isActive: json['isActive'] as bool? ?? true,
      createdAt:
          _readDateTime(json, ['created_at', 'createdAt']) ?? DateTime.now(),
      updatedAt:
          _readDateTime(json, ['updated_at', 'updatedAt']) ?? DateTime.now(),
    );
  }

  // Empty constructor for fallback
  factory VehicleModel.empty() {
    return VehicleModel(
      id: 0,
      vehicleType: 'UNKNOWN',
      vehicleName: '',
      basePrice: '0',
      perKmPrice: '0',
      peakPricing: false,
      dimension: '',
      maxLoad: '',
      isActive: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_type': vehicleType,
      'vehicle_name': vehicleName,
      'base_price': basePrice,
      'per_km_price': perKmPrice,
      'peak_pricing': peakPricing,
      'dimension': dimension,
      'max_load': maxLoad,
      'isActive': isActive,
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
