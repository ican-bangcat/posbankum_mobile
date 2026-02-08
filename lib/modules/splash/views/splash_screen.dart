import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../../app/themes/app_colors.dart';
import '../../../core/constants/image_constants.dart';

/// Splash Screen dengan 4 tahap animasi
class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.showStep1.value) {
          return _buildStep1();
        }
        
        if (controller.showStep2.value || 
            controller.showStep3.value || 
            controller.showStep4.value) {
          return _buildNavyBackground();
        }

        return Container(color: Colors.white);
      }),
    );
  }

  Widget _buildStep1() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Obx(() => AnimatedOpacity(
          opacity: controller.logoOpacity.value,
          duration: const Duration(milliseconds: 500),
          child: AnimatedScale(
            scale: controller.logoScale.value,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            child: Image.asset(
              ImageConstants.logoOutline,
              width: 160, // ✅ LEBIH BESAR (dari 120)
              height: 160,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 80,
                    color: AppColors.primary,
                  ),
                );
              },
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildNavyBackground() {
    return Container(
      color: AppColors.primary,
      child: Column(
        children: [
          // Center content - HANYA LOGO (LEBIH BESAR), TANPA TEXT
          Expanded(
            child: Center(
              child: Obx(() => AnimatedOpacity(
                opacity: controller.showStep3.value 
                    ? controller.logoOpacity.value 
                    : 0.0,
                duration: const Duration(milliseconds: 600),
                child: AnimatedScale(
                  scale: controller.showStep3.value 
                      ? controller.logoScale.value 
                      : 0.8,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  child: Image.asset(
                    ImageConstants.logoWhite,
                    width: 200, // ✅ LEBIH BESAR LAGI (dari 150 jadi 200)
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.shield,
                          size: 120,
                          color: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),
              )),
            ),
          ),
          
          // Building illustration - PAS DI BAWAH
          Obx(() => controller.showStep4.value
              ? AnimatedOpacity(
                  opacity: controller.illustrationOpacity.value,
                  duration: const Duration(milliseconds: 800),
                  child: AnimatedSlide(
                    offset: controller.illustrationOpacity.value > 0
                        ? Offset.zero
                        : const Offset(0, 0.3),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    child: Image.asset(
                      ImageConstants.buildingIllustration,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          width: double.infinity,
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Icon(Icons.gavel, color: Colors.white24, size: 50),
                              SizedBox(width: 20),
                              Icon(Icons.account_balance, color: Colors.white24, size: 60),
                              SizedBox(width: 20),
                              Icon(Icons.location_city, color: Colors.white24, size: 55),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}