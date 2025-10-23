import 'package:faci_tend/core/routes.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppStartController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _decideNextScreen();
  }

  Future<void> _decideNextScreen() async {
    final box = GetStorage();
    final bool isFirstTime = box.read('isFirstTime') ?? true;

    if (isFirstTime) {
      Get.offAllNamed(AppRouter.onBoarding);
    } else {
      // Cuz auth is not yet set up, redirect to login as per now
      Get.offAllNamed(AppRouter.login);
    }
    Future.delayed(const Duration(seconds: 1), () {
      FlutterNativeSplash.remove();
    });
  }
}
