import 'package:ZipBee_Driver/features/home/model/delivery_type_model.dart';

class DeliveryTypeIconHelper {
  /// Maps delivery type icon string or delivery type name to one of the 5 fixed IconPath assets:
  /// - `additional_package` -> DeliveryTypeModel.additional_package
  /// - `express_delivery` -> DeliveryTypeModel.express_delivery
  /// - `helper_team` -> DeliveryTypeModel.helper_team
  /// - `scheduled_delivery` -> DeliveryTypeModel.scheduled_delivery
  /// - `wallet_pricing` -> DeliveryTypeModel.wallet_pricing
  static String? getDeliveryTypeIconPath(
    String? iconName, {
    String? deliveryType,
    int? deliveryTypeId,
  }) {
    return DeliveryTypeModel.getDeliveryTypeIconPath(
      iconName,
      deliveryType: deliveryType,
      deliveryTypeId: deliveryTypeId,
    );
  }
}

