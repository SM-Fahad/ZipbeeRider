import 'package:ZipBee_Driver/core/utils/constants/image_path.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  var images = [
    ImagePath.box2,
    ImagePath.box3,
    ImagePath.boxes,
    ImagePath.box,
  ].obs;

  var riderName = "John Rider".obs;
  var pastOrders = 32.obs;

  // Slide Button
  var dragX = 0.0.obs;
  void resetSlider() => dragX.value = 0;

  var pickupLocations = <Map<String, dynamic>>[
    {
      "title": "Warehouse Pickup",
      "address": "32/4 Main Street, Sector 9, Dhaka",
      "tag": "Primary",
      "subTag": "2 min",
      "isActive": true,
    },
    {
      "title": "Secondary Pickup",
      "address": "Lake Circus, Kalabagan, Dhaka",
      "tag": "",
      "subTag": "",
      "isActive": false,
    },
  ].obs;
}
