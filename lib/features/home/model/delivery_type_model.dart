import 'package:ZipBee_Driver/features/home/service/deliverytype_service.dart';
import 'package:get/get.dart';

class DeliveryTypeModel {
  final int id;
  final String name;
  final String? icon;

  DeliveryTypeModel({
    required this.id,
    required this.name,
    this.icon,
  });

  // delivery_type icons
  static String additional_package = 'assets/icons/delivery_icons/additional_package.png';
  static String express_delivery = 'assets/icons/delivery_icons/express_delivery.png';
  static String helper_team = 'assets/icons/delivery_icons/helper_team.png';
  static String scheduled_delivery = 'assets/icons/delivery_icons/scheduled_delivery.png';
  static String wallet_pricing = 'assets/icons/delivery_icons/wallet_pricing.png';

  /// Parse single DeliveryTypeModel dynamically from API JSON response
  factory DeliveryTypeModel.fromJson(Map<String, dynamic> json) {
    return DeliveryTypeModel(
      id: _readInt(json['id']),
      name: _readString(json['name']),
      icon: json['icon'] as String?,
    );
  }

  /// Parse list of DeliveryTypeModel dynamically from API JSON array
  static List<DeliveryTypeModel> fromJsonList(List<dynamic> list) {
    return list
        .whereType<Map>()
        .map((item) => DeliveryTypeModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  /// Resolved dynamic icon asset path for this delivery type
  String? get iconPath {
    return getDeliveryTypeIconPath(icon, deliveryType: name, deliveryTypeId: id);
  }

  /// Dynamically map delivery type icon string to matching icon asset path.
  /// Resolves strictly via the dynamic 'icon' string from API or order payload.
  static String? getDeliveryTypeIconPath(
    String? iconName, {
    String? deliveryType,
    int? deliveryTypeId,
  }) {
    // 1. Resolve direct iconName string if present (e.g. "additional_package.png" or "wallet_pricing.png")
    if (iconName != null && iconName.trim().isNotEmpty) {
      final asset = _resolveAssetFromIconName(iconName);
      if (asset != null) return asset;
    }

    // 2. Lookup dynamic 'icon' string from cached Delivery Type API response
    final cached = DeliveryTypeService.cachedDeliveryTypes;
    if (cached != null && cached.isNotEmpty) {
      // Find API item by ID
      if (deliveryTypeId != null && deliveryTypeId > 0) {
        final foundById = cached.firstWhereOrNull((dt) => dt.id == deliveryTypeId);
        if (foundById != null && foundById.icon != null && foundById.icon!.isNotEmpty) {
          final asset = _resolveAssetFromIconName(foundById.icon!);
          if (asset != null) return asset;
        }
      }

      // Find API item by Name
      if (deliveryType != null && deliveryType.isNotEmpty) {
        final cleanTypeName = deliveryType.trim().toLowerCase();
        final foundByName = cached.firstWhereOrNull(
          (dt) => dt.name.trim().toLowerCase() == cleanTypeName,
        );
        if (foundByName != null && foundByName.icon != null && foundByName.icon!.isNotEmpty) {
          final asset = _resolveAssetFromIconName(foundByName.icon!);
          if (asset != null) return asset;
        }
      }
    }

    return null;
  }

  static String? _resolveAssetFromIconName(String iconName) {
    final rawIcon = iconName.toLowerCase().trim();
    // Clean filename: remove extension like .png/.jpg and folder paths
    final cleanIcon = rawIcon
        .split('/')
        .last
        .replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '')
        .trim();

    if (cleanIcon.contains('wallet_pricing') || cleanIcon.contains('wallet')) {
      return wallet_pricing;
    }
    if (cleanIcon.contains('additional_package') || cleanIcon.contains('additional') || cleanIcon.contains('package')) {
      return additional_package;
    }
    if (cleanIcon.contains('express_delivery') || cleanIcon.contains('express')) {
      return express_delivery;
    }
    if (cleanIcon.contains('helper_team') || cleanIcon.contains('helper')) {
      return helper_team;
    }
    if (cleanIcon.contains('scheduled_delivery') || cleanIcon.contains('scheduled')) {
      return scheduled_delivery;
    }

    return null;
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


