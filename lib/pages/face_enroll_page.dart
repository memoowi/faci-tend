import 'package:camera/camera.dart';
import 'package:faci_tend/controllers/face_enroll_controller.dart';
import 'package:faci_tend/services/permission_service.dart';
import 'package:faci_tend/widgets/theme_toggle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FaceEnrollPage extends StatelessWidget {
  const FaceEnrollPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FaceEnrollController controller = Get.put(FaceEnrollController());
    final PermissionService permissionService = Get.find<PermissionService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Your Face'),
        actions: [ThemeToggle()],
      ),
      body: Obx(() {
        // --- 1. NEW: Handle Permission Status ---
        final status = controller.cameraPermissionStatus.value;

        if (status == PermissionState.permanentlyDenied) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 100,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  Text(
                    controller.feedbackMessage.value,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () async => permissionService.openAppSetting(),
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            ),
          );
        }

        if (status == PermissionState.denied ||
            status == PermissionState.unknown) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera,
                    size: 100,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    controller.feedbackMessage.value,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: controller.requestPermission,
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            ),
          );
        }

        // --- 2. Handle Camera Initialization ---
        if (!controller.isCameraInitialized.value) {
          // This now just shows a loader while camera initializes
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(controller.feedbackMessage.value),
              ],
            ),
          );
        }

        // --- 3. Build the Camera Stack (This will NOT rebuild) ---
        // Once the camera is initialized, we build the Stack.
        // This Stack will *not* be rebuilt by 'isProcessing'.
        return Stack(
          children: [
            // Camera Preview is the base layer
            Align(
              alignment: Alignment.center,
              child: CameraPreview(controller.cameraController),
            ),

            // Feedback Text
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Obx(
                () => Container(
                  // Only rebuild text
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // color: Colors.black.withAlpha(180),
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

            Align(
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio: 3 / 4,
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

            // Capture Button
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton.large(
                  onPressed: controller.captureAndEnrollFace,
                  shape: CircleBorder(),
                  child: const Icon(Icons.camera_alt),
                ),
              ),
            ),

            // --- 3. THIS IS THE FIX ---
            // Add a processing overlay, wrapped in its *own* Obx.
            // This layer will appear/disappear without rebuilding the camera.
            Obx(() {
              if (!controller.isProcessing.value) {
                // If not processing, return an empty, non-blocking container
                return const SizedBox.shrink();
              }

              // If processing, show the loading UI
              return Container(
                color: Colors.black.withAlpha(180),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
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
            // --- END FIX ---
          ],
        );
      }),
    );
  }
}
