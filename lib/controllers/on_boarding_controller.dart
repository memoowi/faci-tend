import 'package:faci_tend/core/routes.dart';
import 'package:faci_tend/models/on_boarding_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OnBoardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final List<OnBoardingInfo> onBoardingData = [
    OnBoardingInfo(
      imagePath: 'assets/images/radar.png',
      title: 'Precise Location Tracking',
      subtitle:
          'Clock in and out with GPS verification to ensure you are at the correct location.',
    ),
    OnBoardingInfo(
      imagePath: 'assets/images/face-scan.png',
      title: 'Secure Face Recognition',
      subtitle:
          'Your face is your password. We use on-device AI for secure and fast identity verification.',
    ),
    OnBoardingInfo(
      imagePath: 'assets/images/file.png',
      title: 'View Your History',
      subtitle:
          'Easily track your attendance history and review all your clock-in and out records.',
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void completeOnboarding() {
    final appData = GetStorage();
    appData.write('isFirstTime', false);

    Get.offAllNamed(AppRouter.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
