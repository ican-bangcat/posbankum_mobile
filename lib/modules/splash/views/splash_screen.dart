import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../../app/themes/app_colors.dart';
import '../../../core/constants/image_constants.dart';

/// Splash Screen dengan Animasi Wave Reveal Kiri Bawah & Layout Horizontal Estetik
class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller.animController,
          builder: (context, child) {
            return Stack(
              children: [
                // 1. LAYAR PUTIH AWAL (Logo Elang besar di tengah)
                _buildWhiteStep(),

                // 2. LAYAR NAVY DENGAN EFEK OMBAK (Wave Reveal dari Kiri Bawah)
                ClipPath(
                  clipper: BottomLeftWaveClipper(controller.waveAnimation.value),
                  child: Container(
                    color: AppColors.primary,
                    width: double.infinity,
                    height: double.infinity,
                    child: Stack(
                      children: [
                        // Logo + Teks Horizontal di Tengah Layar
                        Center(
                          child: FadeTransition(
                            opacity: controller.navyContentOpacity,
                            child: SlideTransition(
                              position: controller.navyContentSlide,
                              child: _buildHorizontalLogoRow(),
                            ),
                          ),
                        ),

                        // Building Illustration di Dasar Layar
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: FadeTransition(
                            opacity: controller.buildingOpacity,
                            child: SlideTransition(
                              position: controller.buildingSlide,
                              child: Image.asset(
                                ImageConstants.buildingIllustration,
                                width: double.infinity,
                                height: 160,
                                fit: BoxFit.cover,
                                alignment: Alignment.bottomCenter,
                                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Layar Putih Awal - Logo Elang besar di tengah
  Widget _buildWhiteStep() {
    return Center(
      child: FadeTransition(
        opacity: controller.step1LogoOpacity,
        child: ScaleTransition(
          scale: controller.step1LogoScale,
          child: Image.asset(
            ImageConstants.logoOutline,
            width: 170,
            height: 170,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: const Icon(Icons.gavel, size: 80, color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  /// Layout Horizontal: Logo Elang (kiri) + Teks Posbankum Provinsi Riau (kanan)
  Widget _buildHorizontalLogoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Maskot Elang Putih
        Image.asset(
          ImageConstants.logoWhite,
          width: 90,
          height: 90,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.gavel_rounded,
            size: 70,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        // Teks Posbankum Provinsi Riau
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Posbankum',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
                height: 1.1,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Provinsi Riau',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Custom Clipper untuk Efek Ombak / Ripple dari Kiri Bawah Layar
class BottomLeftWaveClipper extends CustomClipper<Path> {
  final double progress;

  BottomLeftWaveClipper(this.progress);

  @override
  Path getClip(Size size) {
    final path = Path();
    if (progress <= 0.0) {
      return path; // Kosong
    }

    // Jarak maksimum dari sudut kiri bawah ke sudut kanan atas
    final maxRadius = sqrt(size.width * size.width + size.height * size.height);
    final currentRadius = maxRadius * progress;

    path.addOval(
      Rect.fromCircle(
        center: Offset(0, size.height), // Sudut Kiri Bawah
        radius: currentRadius,
      ),
    );

    return path;
  }

  @override
  bool shouldReclip(covariant BottomLeftWaveClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}