import 'package:ZipBee_Driver/features/home/service/deliverytype_service.dart';
import 'package:ZipBee_Driver/features/home/model/delivery_type_model.dart';
import 'package:get/get.dart';

class RiderCardController extends GetxController {
  final DeliveryTypeService _deliveryTypeService = DeliveryTypeService();
  final Rx<String?> deliveryTypeName = Rx<String?>(null);
  final Rx<String?> deliveryTypeIconPath = Rx<String?>(null);

  Future<void> fetchDeliveryTypeName(
    int deliveryTypeId,
    String fallbackName, {
    String? fallbackIcon,
  }) async {
    // Immediately set best available icon from fallback or cache
    deliveryTypeName.value = fallbackName;
    deliveryTypeIconPath.value = DeliveryTypeModel.getDeliveryTypeIconPath(
      fallbackIcon,
      deliveryType: fallbackName,
      deliveryTypeId: deliveryTypeId,
    );

    try {
      final deliveryTypes = await _deliveryTypeService.fetchDeliveryTypes();

      // Match by ID first
      if (deliveryTypeId > 0) {
        for (final dt in deliveryTypes) {
          if (dt.id == deliveryTypeId) {
            deliveryTypeName.value = dt.name;
            deliveryTypeIconPath.value = dt.iconPath;
            return;
          }
        }
      }

      // Match by Name second
      final cleanFallback = fallbackName.trim().toLowerCase();
      if (cleanFallback.isNotEmpty) {
        for (final dt in deliveryTypes) {
          if (dt.name.trim().toLowerCase() == cleanFallback) {
            deliveryTypeName.value = dt.name;
            deliveryTypeIconPath.value = dt.iconPath;
            return;
          }
        }
      }
    } catch (_) {
      // Keep initialized icon path
    }
  }
}
