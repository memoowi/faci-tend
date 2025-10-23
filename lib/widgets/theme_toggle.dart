import 'package:faci_tend/themes/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeToggle extends StatelessWidget {
  ThemeToggle({super.key});

  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => IconButton(
        icon: Icon(
          themeController.themeMode == ThemeMode.light
              ? Icons.dark_mode_outlined
              : Icons.light_mode_outlined,
        ),
        onPressed: () {
          themeController.toggleTheme();
        },
      ),
    );
  }
}
