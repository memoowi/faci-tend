import 'package:faci_tend/core/routes.dart';
import 'package:faci_tend/themes/app_theme.dart';
import 'package:faci_tend/themes/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await GetStorage.init();
  Get.put(ThemeController(), permanent: true);
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: 'FaciTend',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRouter.initialRoute,
        getPages: AppRouter.routes,
      ),
    );
  }
}
