import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../controllers/onboarding_controller.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';

/// Onboarding Screen - Super Smooth Animations dengan Transisi Mengecil dari Splash
class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller.entranceController,
          builder: (context, child) {
            final isDone = controller.shrinkProgress.value >= 1.0;
            return Stack(
              children: [
                // 1. KONTEN ONBOARDING (Fade-in saat navy mengecil)
                FadeTransition(
                  opacity: controller.uiOpacity,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 650),
                      child: Column(
                        children: [
                          _buildSkipButton(),
                          Expanded(
                            child: PageView.builder(
                              controller: controller.pageController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: controller.totalPages,
                              onPageChanged: (index) => controller.currentPage.value = index,
                              itemBuilder: (context, index) => _OnboardingPage(
                                data: controller.pages[index],
                                pageIndex: index,
                                currentPage: controller.currentPage,
                              ),
                            ),
                          ),
                          _buildBottomSection(),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. NAVY OVERLAY TRANSITION (Mengecil dari Penuh ke Lingkaran Onboarding 1)
                if (!isDone)
                  ClipPath(
                    clipper: ReverseRadialShrinkClipper(controller.shrinkProgress.value),
                    child: Container(
                      color: AppColors.primary,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: controller.skip,
          child: const Text('Lewati', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SmoothPageIndicator(
            controller: controller.pageController,
            count: controller.totalPages,
            effect: const ExpandingDotsEffect(
              dotWidth: 8,
              dotHeight: 8,
              activeDotColor: AppColors.indicatorActive,
              dotColor: AppColors.indicatorInactive,
              expansionFactor: 3,
            ),
          ),
          const SizedBox(height: 32),
          Obx(() => _SmoothButton(
                key: ValueKey(controller.currentPage.value),
                onPressed: controller.nextPage,
                text: controller.currentPage.value < controller.totalPages - 1 ? 'Lanjut' : 'Mulai',
              )),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final int pageIndex;
  final RxInt currentPage;

  const _OnboardingPage({
    required this.data,
    required this.pageIndex,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Obx(() {
            final isActive = currentPage.value == pageIndex;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                    ),
                    child: child,
                  ),
                );
              },
              child: isActive
                  ? Container(
                      key: ValueKey(pageIndex),
                      width: 250,
                      height: 250,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                      child: Center(
                        child: Image.asset(
                          data.imageAsset,
                          width: 200,
                          height: 200,
                          errorBuilder: (c, e, s) => const Icon(Icons.shield, size: 100, color: Colors.white),
                        ),
                      ),
                    )
                  : Container(
                      key: ValueKey('inactive_$pageIndex'),
                      width: 250,
                      height: 250,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                    ),
            );
          }),
          const SizedBox(height: 48),
          Obx(() {
            final isActive = currentPage.value == pageIndex;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    ),
                    child: child,
                  ),
                );
              },
              child: isActive
                  ? Text(
                      data.title,
                      key: ValueKey('title_$pageIndex'),
                      style: AppTextStyles.onboardingTitle,
                      textAlign: TextAlign.center,
                    )
                  : const SizedBox.shrink(),
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            final isActive = currentPage.value == pageIndex;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    ),
                    child: child,
                  ),
                );
              },
              child: isActive
                  ? Text(
                      data.description,
                      key: ValueKey('desc_$pageIndex'),
                      style: AppTextStyles.onboardingDescription,
                      textAlign: TextAlign.center,
                    )
                  : const SizedBox.shrink(),
            );
          }),
        ],
      ),
    );
  }
}

class _SmoothButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const _SmoothButton({super.key, required this.onPressed, required this.text});

  @override
  State<_SmoothButton> createState() => _SmoothButtonState();
}

class _SmoothButtonState extends State<_SmoothButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 80), vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 - (_controller.value * 0.04);
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.buttonPrimary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Center(child: Text(widget.text, style: AppTextStyles.buttonLarge)),
        ),
      ),
    );
  }
}

/// Custom Clipper untuk Efek Navy Mengecil dari Layar Penuh ke Lingkaran Onboarding 1
class ReverseRadialShrinkClipper extends CustomClipper<Path> {
  final double progress;

  ReverseRadialShrinkClipper(this.progress);

  @override
  Path getClip(Size size) {
    final path = Path();
    if (progress >= 1.0) {
      return path; // Kosong / Selesai
    }

    // Pusat lingkaran mascot Onboarding 1 (tengah horizontal, Y sekitar 165px dari top)
    final targetCenter = Offset(size.width / 2, 165.0);
    const targetRadius = 125.0; // Lingkaran diameter 250px

    final maxRadius = sqrt(size.width * size.width + size.height * size.height);
    // Interpolasi radius dari layar penuh (0.0) ke lingkaran kecil (1.0)
    final currentRadius = maxRadius - ((maxRadius - targetRadius) * progress);

    final currentCenter = Offset.lerp(
      Offset(size.width / 2, size.height / 2),
      targetCenter,
      progress,
    )!;

    path.addOval(
      Rect.fromCircle(
        center: currentCenter,
        radius: currentRadius,
      ),
    );

    return path;
  }

  @override
  bool shouldReclip(covariant ReverseRadialShrinkClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}