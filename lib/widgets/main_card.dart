import 'package:faci_tend/core/routes.dart';
import 'package:faci_tend/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainCard extends StatelessWidget {
  const MainCard({super.key, required this.userService});

  final UserService userService;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
