import 'package:faci_tend/services/user_service.dart';
import 'package:faci_tend/widgets/theme_toggle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final UserService userService = Get.find<UserService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          ThemeToggle(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await userService.logout();
            },
          ),
        ],
      ),
      body: const Center(child: Text('Home Page')),
    );
  }
}
