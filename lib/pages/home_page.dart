import 'package:faci_tend/controllers/history_controller.dart';
import 'package:faci_tend/services/user_service.dart';
import 'package:faci_tend/utils/helper.dart';
import 'package:faci_tend/widgets/main_card.dart';
import 'package:faci_tend/widgets/profile_info.dart';
import 'package:faci_tend/widgets/theme_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final UserService userService = Get.find<UserService>();
  final HistoryController historyController = Get.put(HistoryController());

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MainCard(userService: userService),
            const SizedBox(height: 16.0),
            Obx(() {
              if (historyController.attendances.isEmpty) {
                return const Text('No attendance records');
              }
              return Text(
                'Attendance History',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              );
            }),
            const SizedBox(height: 8.0),
            Obx(
              () => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: historyController.attendances.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, index) {
                  final attendance = historyController.attendances[index];
                  return ListTile(
                    onTap: () async {
                      try {
                        await Helper.openMap(attendance.location);
                      } catch (e) {
                        // Display error using GetX snackbar
                        Helper.showError('Failed to open map: $e');
                      }
                    },
                    title: Text(attendance.type),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LatLang: ${attendance.location.latitude}, ${attendance.location.longitude}',
                        ),
                        Text(
                          'Distance: ${attendance.distanceToTargetMeters.toStringAsFixed(2)} meters',
                        ),
                      ],
                    ),
                    subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
                    trailing: Text(
                      Helper.formattedTime(attendance.timestamp.toDate()),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
