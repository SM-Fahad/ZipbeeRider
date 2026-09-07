import 'package:get/get.dart';

class PickupDetailController extends GetxController {
  var riderName = "Harry Johnson".obs;
  var pastOrders = 32.obs;

  var pickupLocations = [
    {
      "title": "Punggol",
      "address": "Block 666 Punggol Drive #15-32\nSingapore 828665",
      "tag": "Pending Pick Up",
      "isActive": true,
      "distance": "",
      "time": "",
    },
    {
      "title": "Boon Keng",
      "address": "32 Boon Keng Ave #04-144\nSingapore 530032",
      "tag": "",
      "isActive": false,
      "distance": "8.9KM",
      "time": "13 Mins",
    },
  ].obs;

  var remarks =
      "Please send it to Mr. Alex. Contact *********\n(Censored the mobile number)"
          .obs;

  /// MUST USE REAL IMAGE PATHS ONLY
  var pickupImages = [
    "assets/images/box1.png",
    "assets/images/box2.png",
    "assets/images/box3.png",
  ].obs;

  /// SLIDER VALUES
  var dragX = 0.0.obs;
}
