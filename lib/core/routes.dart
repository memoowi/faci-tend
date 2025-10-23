import 'package:faci_tend/pages/home_page.dart';
import 'package:faci_tend/pages/login_page.dart';
import 'package:faci_tend/pages/on_boarding_page.dart';
import 'package:faci_tend/pages/register_page.dart';
import 'package:get/get.dart';

class AppRouter {
  static const String onBoarding = '/onBoarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';

  static const String initialRoute = onBoarding;

  static final List<GetPage> routes = [
    GetPage(name: home, page: () => HomePage()),
    GetPage(name: onBoarding, page: () => OnBoardingPage()),
    GetPage(name: login, page: () => LoginPage()),
    GetPage(name: register, page: () => RegisterPage()),
  ];
}
