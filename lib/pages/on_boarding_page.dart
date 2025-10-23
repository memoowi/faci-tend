import 'package:faci_tend/controllers/on_boarding_controller.dart';
import 'package:faci_tend/widgets/on_boarding_content.dart';
import 'package:faci_tend/widgets/theme_toggle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OnBoardingController controller = Get.put(OnBoardingController());

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              children: controller.onBoardingData
                  .map((data) => OnBoardingContent(data: data))
                  .toList(),
            ),

            Positioned(
              top: 16,
              right: 16,
              left: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ThemeToggle(),
                  TextButton(
                    onPressed: controller.completeOnboarding,
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Row(
                      children: List.generate(
                        controller.onBoardingData.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: controller.currentPage.value == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: controller.currentPage.value == index
                                ? context.theme.colorScheme.primary
                                : context.theme.colorScheme.onSurface.withAlpha(
                                    40,
                                  ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Obx(
                    () => FloatingActionButton(
                      elevation: 0,
                      focusElevation: 0,
                      hoverElevation: 0,
                      highlightElevation: 0,
                      shape: const CircleBorder(),
                      onPressed:
                          controller.currentPage.value ==
                              controller.onBoardingData.length - 1
                          ? controller.completeOnboarding
                          : controller.nextPage,
                      child: Icon(
                        controller.currentPage.value ==
                                controller.onBoardingData.length - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                      ),
                    ),
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
