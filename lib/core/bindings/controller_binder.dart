
import 'package:ZipBee_Driver/features/auto_popup/controller/auto_popup_controller.dart';
import 'package:get/get.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.put<AutoPopupController>(AutoPopupController(), permanent: true);
  }
}
