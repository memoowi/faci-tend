import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Helper {
  static onTapOutside(event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withAlpha(180),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
