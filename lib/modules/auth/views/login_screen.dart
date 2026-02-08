import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import 'register_modal.dart'; // ✅ 1. IMPORT MODAL REGISTER

/// Main Login Screen - 2 Button (Masuk & Daftar)
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // ✅ 2. FUNGSI UNTUK MEMUNCULKAN MODAL
  void _showRegisterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RegisterModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      _buildLogo(),
                      const SizedBox(height: 80),
                      _buildButtons(context), // ✅ Kirim Context ke sini
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomIllustration(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo/logo_posbankum.png',
      width: 180,
      height: 180,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.shield, size: 100, color: Colors.white),
        );
      },
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        _AnimatedButton(
          onPressed: () {
            // Tombol MASUK -> Pindah ke Halaman Form Login
            Get.toNamed(AppRoutes.LOGIN_FORM);
          },
          isPrimary: true,
          child: const Text('MASUK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 16),
        _AnimatedButton(
          onPressed: () {
            // Tombol DAFTAR -> Buka Modal Register (JANGAN PINDAH HALAMAN)
            _showRegisterModal(context);
          },
          isPrimary: false,
          child: const Text('DAFTAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildBottomIllustration() {
    return Image.asset(
      'assets/images/icons/building_illustration2.png',
      width: double.infinity,
      height: 160,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => Container(height: 160, color: Colors.grey[100]),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool isPrimary;

  const _AnimatedButton({required this.onPressed, required this.child, this.isPrimary = true});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
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
          final scale = 1.0 - (_controller.value * 0.05);
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: widget.isPrimary ? AppColors.buttonPrimary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: widget.isPrimary ? null : Border.all(color: AppColors.primary, width: 2),
          ),
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(color: widget.isPrimary ? Colors.white : AppColors.primary),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}