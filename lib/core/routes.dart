import 'package:faci_tend/bindings/auth_binding.dart';
import 'package:faci_tend/pages/attendance_page.dart';
import 'package:faci_tend/pages/face_enroll_page.dart';
import 'package:faci_tend/pages/home_page.dart';
import 'package:faci_tend/pages/login_page.dart';
import 'package:faci_tend/pages/on_boarding_page.dart';
import 'package:faci_tend/pages/register_page.dart';
import 'package:faci_tend/pages/start_page.dart';
import 'package:get/get.dart';

class AppRouter {
  static const String start = '/';
  static const String onBoarding = '/onBoarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String faceEnroll = '/faceEnroll';
  static const String takeAttendance = '/takeAttendance';

  static const String initialRoute = start;

  static final List<GetPage> routes = [
    GetPage(name: start, page: () => StartPage()),
    GetPage(name: home, page: () => HomePage()),
    GetPage(name: onBoarding, page: () => OnBoardingPage()),
    GetPage(name: login, page: () => LoginPage(), binding: AuthBinding()),
    GetPage(name: register, page: () => RegisterPage(), binding: AuthBinding()),
    GetPage(name: faceEnroll, page: () => FaceEnrollPage()),
    GetPage(name: takeAttendance, page: () => AttendancePage()),
  ];
}
