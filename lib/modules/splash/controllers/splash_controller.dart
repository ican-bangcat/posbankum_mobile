import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';

/// Splash Controller - Handle animasi splash screen dan navigation logic
class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  final storage = GetStorage();

  late AnimationController animController;
  late Animation<double> waveAnimation;
  late Animation<double> step1LogoScale;
  late Animation<double> step1LogoOpacity;
  late Animation<double> navyContentOpacity;
  late Animation<Offset> navyContentSlide;
  late Animation<double> buildingOpacity;
  late Animation<Offset> buildingSlide;

  var isWaveStarted = false.obs;

  @override
  void onInit() {
    super.onInit();

    animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // 0.0 - 0.25: Step 1 (Logo Elang muncul di layar putih)
    step1LogoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: animController,
        curve: const Interval(0.0, 0.20, curve: Curves.easeOutBack),
      ),
    );

    step1LogoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animController,
        curve: const Interval(0.0, 0.15, curve: Curves.easeIn),
      ),
    );

    // 0.25 - 0.50: Wave Navy dari kiri bawah mengembang memenuhi layar
    waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animController,
        curve: const Interval(0.25, 0.50, curve: Curves.easeInOutCubic),
      ),
    );

    // 0.45 - 0.70: Content Navy (Logo + Teks Horizontal muncul di tengah)
    navyContentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animController,
        curve: const Interval(0.48, 0.68, curve: Curves.easeOut),
      ),
    );

    navyContentSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: animController,
        curve: const Interval(0.48, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    // 0.65 - 0.90: Building illustration meluncur dari bawah dasar layar
    buildingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animController,
        curve: const Interval(0.65, 0.85, curve: Curves.easeOut),
      ),
    );

    buildingSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
      CurvedAnimation(
        parent: animController,
        curve: const Interval(0.65, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    // Start playback
    startSplashAnimation();
  }

  void startSplashAnimation() async {
    await animController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    navigateToNext();
  }

  void navigateToNext() async {
    // Cek status onboarding
    final hasSeenOnboarding = storage.read('onboarding_completed') ?? false;
    
    // Cek status login
    final isLoggedIn = storage.read('is_logged_in') ?? false;
    final role = storage.read('role') ?? '';
    
    if (isLoggedIn) {
      _redirectBasedOnRole(role);
    } else if (hasSeenOnboarding) {
      Get.offAllNamed(AppRoutes.LOGIN);
    } else {
      Get.offAllNamed(AppRoutes.ONBOARDING);
    }
  }

  void _redirectBasedOnRole(String role) {
    final String userRole = role.toLowerCase().trim();
    if (userRole == 'warga' || userRole == 'pelapor' || userRole == 'masyarakat') {
      Get.offAllNamed(AppRoutes.WARGA_DASHBOARD);
    } else if (userRole == 'paralegal' || userRole == 'admin' || userRole == 'posbankum') {
      Get.offAllNamed(AppRoutes.PARALEGAL_DASHBOARD);
    } else {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  @override
  void onClose() {
    animController.dispose();
    super.onClose();
  }
}