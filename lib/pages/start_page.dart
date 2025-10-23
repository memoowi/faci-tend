import 'package:faci_tend/controllers/app_start_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StartPage extends StatelessWidget {
  StartPage({super.key});

  final AppStartController controller = Get.put(AppStartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const Center(child: CircularProgressIndicator()));
  }
}
