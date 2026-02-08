import 'package:get/get.dart';
import '../../modules/splash/views/splash_screen.dart';
import '../../modules/splash/controllers/splash_controller.dart';
import '../../modules/onboarding/views/onboarding_screen.dart';
import '../../modules/onboarding/controllers/onboarding_controller.dart';
import '../../modules/auth/views/login_screen.dart';
import '../../modules/auth/views/login_form_screen.dart';
import 'app_routes.dart';

/// App Pages Configuration
class AppPages {
  AppPages._();

  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SplashController>(() => SplashController());
      }),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => const OnboardingScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OnboardingController>(() => OnboardingController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 600),
    ),

    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    GetPage(
      name: AppRoutes.LOGIN_FORM,
      page: () => const LoginFormScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}