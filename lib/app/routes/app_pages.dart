import 'package:get/get.dart';
import '../../modules/splash/views/splash_screen.dart';
import '../../modules/splash/controllers/splash_controller.dart';
import '../../modules/onboarding/views/onboarding_screen.dart';
import '../../modules/onboarding/controllers/onboarding_controller.dart';
import '../../modules/auth/views/login_screen.dart';
import '../../modules/auth/views/login_form_screen.dart';
import '../../modules/auth/views/home_masyarakat_screen.dart';
import '../../modules/auth/views/home_paralegal_screen.dart';
import '../../modules/pengaduan/views/form_pengaduan_screen.dart';
import '../../modules/pengaduan/views/pengaduan_success_screen.dart';
import '../../modules/pengaduan/controllers/pengaduan_controller.dart';
import '../../modules/auth/views/forgot_password_screen.dart';
import '../../modules/auth/controllers/forgot_password_controller.dart';
import '../../modules/auth/views/update_password_screen.dart';
import '../../modules/auth/controllers/update_password_controller.dart';
import '../../modules/riwayatPengaduan/views/riwayat_pengaduan_view.dart';
import '../../modules/riwayatPengaduan/controllers/riwayat_pengaduan_controller.dart';
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

    // Home Masyarakat
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeMasyarakatScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // ✅ FORGOT PASSWORD (BARU)
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
      binding: BindingsBuilder(() {
        // LazyPut: Controller hanya dibuat saat halaman dibuka
        Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ✅ UPDATE PASSWORD (BARU)
    GetPage(
      name: AppRoutes.UPDATE_PASSWORD,
      page: () => const UpdatePasswordScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<UpdatePasswordController>(() => UpdatePasswordController());
      }),
      transition: Transition.fadeIn, // Fade in karena ini biasanya otomatis
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // ✅ PENGADUAN ROUTES (SUDAH DISESUAIKAN)
    GetPage(
      name: AppRoutes.FORM_PENGADUAN,
      page: () => const FormPengaduanScreen(),
      binding: BindingsBuilder(() {
        // Wajib inject Controller di sini biar gak error!
        Get.lazyPut<PengaduanController>(() => PengaduanController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.PENGADUAN_SUCCESS,
      page: () {
        // Ambil pengaduanId dari arguments yang dikirim controller
        final pengaduanId = Get.arguments as String? ?? 'PGN-UNKNOWN';
        return PengaduanSuccessScreen(pengaduanId: pengaduanId);
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    // ✅ RIWAYAT PENGADUAN
    GetPage(
      name: AppRoutes.RIWAYAT_PENGADUAN,
      page: () => const RiwayatPengaduanView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RiwayatPengaduanController>(() => RiwayatPengaduanController());
      }),
      transition: Transition.rightToLeft, // Animasi geser dari kanan
    ),
  ];
}