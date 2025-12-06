import 'package:faci_tend/core/routes.dart';
import 'package:faci_tend/services/user_service.dart';
import 'package:faci_tend/widgets/profile_info.dart';
import 'package:faci_tend/widgets/theme_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final UserService userService = Get.find<UserService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dotenv.get("APP_NAME")),
        actions: [
          ThemeToggle(),
          IconButton(
            icon: const Icon(Icons.person_outline),
            // onPressed: () async {
            //   await userService.logout();
            // },
            onPressed: () {
              // open sheet
              Get.bottomSheet(
                ProfileInfo(userService: userService),
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.0),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${userService.firestoreUser.value?.displayName ?? ''}!',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'You are logged in as ${userService.firestoreUser.value?.email ?? ''}',
                    style: context.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.toNamed(AppRouter.takeAttendance);
                          },
                          icon: const Icon(Icons.schedule),
                          label: const Text('Take Attendance'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
