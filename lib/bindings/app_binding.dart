import 'package:faci_tend/controllers/user_controller.dart';
import 'package:get/get.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure navigation context rdy
    Get.put(UserController(), permanent: true);
  }
}
