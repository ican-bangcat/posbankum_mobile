import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';  // ✅ BENAR

/// Onboarding Controller
/// Menghandle page controller dan navigasi onboarding
class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final storage = GetStorage();
  
  // Current page index
  var currentPage = 0.obs;
  
  // Total pages
  final int totalPages = 3;

  // Onboarding data
  final List<OnboardingData> pages = [
    OnboardingData(
      title: 'Ajukan Pengaduan Hukum dengan Mudah',
      description: 'Ajukan pengaduan hukum dengan cepat dan mudah isi formulir, unggah bukti, lalu pantau statusnya.',
      imageAsset: 'assets/images/onboarding/onboarding_1.png',
    ),
    OnboardingData(
      title: 'Pantau Status Pengaduan Anda',
      description: 'Pantau update pengaduan hukum Anda secara real-time, dari pengajuan hingga penyelesaian.',
      imageAsset: 'assets/images/onboarding/onboarding_2.png',
    ),
    OnboardingData(
      title: 'Paralegal Siap Membantu Anda',
      description: 'Tim paralegal kami siap memberikan bantuan hukum gratis untuk memastikan keadilan bagi Anda.',
      imageAsset: 'assets/images/onboarding/onboarding_3.png',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    pageController.addListener(() {
      currentPage.value = pageController.page?.round() ?? 0;
    });
  }

  /// Next page
  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Halaman terakhir, navigasi ke login
      completeOnboarding();
    }
  }

  /// Skip onboarding
  void skip() {
    completeOnboarding();
  }

  /// Complete onboarding dan simpan flag
  void completeOnboarding() async {
    // Simpan flag bahwa user sudah lihat onboarding
    await storage.write('onboarding_completed', true);
    
    // Navigate ke login
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  /// Cek apakah user sudah pernah lihat onboarding
  static Future<bool> hasCompletedOnboarding() async {
    final storage = GetStorage();
    return storage.read('onboarding_completed') ?? false;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

/// Model untuk data onboarding
class OnboardingData {
  final String title;
  final String description;
  final String imageAsset;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imageAsset,
  });
}
