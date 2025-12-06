import 'dart:math' as math;

import 'package:faci_tend/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({
    super.key,
    required this.userService,
  });

  final UserService userService;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Transform.rotate(
            angle: -math.pi / 2,
            child: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                Get.back();
              },
            ),
          ),
          const SizedBox(height: 16.0),
          CircleAvatar(
            radius: 64,
            foregroundImage:
                userService.firestoreUser.value!.faceImageUrl !=
                    null
                ? NetworkImage(
                    userService.firestoreUser.value!.faceImageUrl!,
                  )
                : null,
          ),
          const SizedBox(height: 16.0),
          Text(
            userService.firestoreUser.value!.displayName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8.0),
          Text(
            userService.firestoreUser.value!.email,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16.0),
          FilledButton.icon(
            onPressed: () async {
              await userService.logout();
              Get.back();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            label: const Text('Logout'),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
