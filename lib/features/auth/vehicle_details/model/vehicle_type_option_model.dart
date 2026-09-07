class VehicleTypeOptionModel {
  final int id;
  final String vehicleType;
  final String vehicleName;

  VehicleTypeOptionModel({
    required this.id,
    required this.vehicleType,
    required this.vehicleName,
  });

  factory VehicleTypeOptionModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeOptionModel(
      id: _readInt(json['id']),
      vehicleType: _readString(json['vehicle_type']),
      vehicleName: _readString(json['vehicle_name']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static String _readString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }
}
