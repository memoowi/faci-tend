import 'package:faci_tend/services/cloudinary_service.dart';
import 'package:faci_tend/services/permission_service.dart';
import 'package:faci_tend/services/user_service.dart';
import 'package:get/get.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure navigation context rdy
    Get.put(UserService(), permanent: true);
    Get.put(PermissionService(), permanent: true);
    Get.put(CloudinaryService(), permanent: true);
  }
}
