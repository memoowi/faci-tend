import 'package:camera/camera.dart';
import 'package:faci_tend/controllers/attendance_controller.dart';
import 'package:faci_tend/services/permission_service.dart';
import 'package:faci_tend/widgets/theme_toggle.dart'; // Assuming this exists
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Initialize the new Attendance Controller
    final AttendanceController controller = Get.put(AttendanceController());
    final PermissionService permissionService = Get.find<PermissionService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock In Attendance'),
        actions: [ThemeToggle()],
      ),
      body: Obx(() {
        // --- 1. Handle Permissions (Camera & Location) ---
        // Since we check both in the controller's init, we rely on the
        // feedbackMessage to guide the user on which permission to grant.

        final isInitialized = controller.isCameraInitialized.value;
        final isCameraPermitted = controller.cameraPermissionStatus.value;
        final isLocationPermitted = controller.locationPermissionStatus.value;

        // If camera hasn't fully initialized OR the controller is still
        // checking permissions (meaning isInitialized is false), show status.
        if (!isInitialized ||
            isLocationPermitted != PermissionState.granted ||
            isCameraPermitted != PermissionState.granted) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Show a relevant icon based on the message
                  if (controller.feedbackMessage.value.contains('permission'))
                    Icon(
                      Icons.security,
                      size: 80,
                      color: Theme.of(context).colorScheme.tertiary,
                    )
                  else
                    const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    controller.feedbackMessage.value,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  // Provide a button to open settings if permission is mentioned
                  if (controller.feedbackMessage.value.contains('permission'))
                    FilledButton(
                      onPressed: () {
                        isLocationPermitted ==
                                    PermissionState.permanentlyDenied ||
                                isCameraPermitted ==
                                    PermissionState.permanentlyDenied
                            ? permissionService.openAppSetting()
                            : controller.requestPermission();
                      },
                      child: const Text('Grant Required Permissions'),
                    ),
                ],
              ),
            ),
          );
        }

        // --- 2. Build the Camera Stack (Only when fully initialized) ---
        return Stack(
          fit: StackFit.expand, // Use expand to ensure fullscreen camera
          children: [
            Align(
              alignment: Alignment.center,
              child: CameraPreview(controller.cameraController!),
            ),

            // Mask/Oval Outline (Visual Guide for the face)
            Align(
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio:
                    3 / 4, // Use a vertical aspect ratio for the oval guide
                child: Container(
                  margin: const EdgeInsets.all(64),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(140),
                    border: Border.all(
                      color: Colors.white.withAlpha(180),
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),

            // Feedback Text
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Obx(
                () => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    controller.feedbackMessage.value,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),

            // Clock In Button
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Obx(
                  () => FloatingActionButton.extended(
                    onPressed: controller.isProcessing.value
                        ? null
                        : controller.clockIn, // Call the attendance logic
                    shape: const StadiumBorder(),
                    label: Text(
                      controller.isProcessing.value
                          ? 'Verifying...'
                          : 'Clock In',
                      style: const TextStyle(fontSize: 18),
                    ),
                    icon: controller.isProcessing.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline),
                  ),
                ),
              ),
            ),

            // Processing Overlay (Covers the screen during verification)
            Obx(() {
              if (!controller.isProcessing.value) {
                return const SizedBox.shrink();
              }
              return Container(
                color: Colors.black.withAlpha(180),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 20),
                      Text(
                        controller.feedbackMessage.value,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
