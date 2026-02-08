import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';

/// Splash Controller - Handle animasi splash screen dan navigation logic
class SplashController extends GetxController {
  final storage = GetStorage();
  
  var showStep1 = false.obs;
  var showStep2 = false.obs;
  var showStep3 = false.obs;
  var showStep4 = false.obs;

  var logoOpacity = 0.0.obs;
  var textOpacity = 0.0.obs;
  var illustrationOpacity = 0.0.obs;
  var logoScale = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    startSplashAnimation();
  }

  void startSplashAnimation() async {
    // Step 1: Logo outline (0.8s)
    await Future.delayed(const Duration(milliseconds: 100));
    showStep1.value = true;
    logoScale.value = 0.8;
    logoOpacity.value = 1.0;
    await Future.delayed(const Duration(milliseconds: 800));

    logoOpacity.value = 0.0;
    await Future.delayed(const Duration(milliseconds: 300));

    // Step 2: Navy background (0.5s)
    showStep1.value = false;
    showStep2.value = true;
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 3: Logo + text (1.2s)
    showStep3.value = true;
    logoScale.value = 1.0;
    logoOpacity.value = 1.0;
    await Future.delayed(const Duration(milliseconds: 300));
    textOpacity.value = 1.0;
    await Future.delayed(const Duration(milliseconds: 900));

    // Step 4: Building illustration (1.2s)
    showStep4.value = true;
    illustrationOpacity.value = 1.0;
    await Future.delayed(const Duration(milliseconds: 1200));

    // Navigate berdasarkan status
    navigateToNext();
  }

  void navigateToNext() async {
    // Cek status onboarding
    final hasSeenOnboarding = storage.read('onboarding_completed') ?? false;
    
    // Cek status login (nanti akan diimplementasi)
    final isLoggedIn = storage.read('is_logged_in') ?? false;
    
    // Logic navigation:
    if (isLoggedIn) {
      // Jika sudah login → ke Home
      // TODO: Implement Home route nanti
      Get.offAllNamed(AppRoutes.LOGIN); // Sementara ke login dulu
    } else if (hasSeenOnboarding) {
      // Jika sudah pernah onboarding tapi belum login → ke Login
      Get.offAllNamed(AppRoutes.LOGIN);
    } else {
      // Jika belum pernah onboarding → ke Onboarding
      Get.offAllNamed(AppRoutes.ONBOARDING);
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}