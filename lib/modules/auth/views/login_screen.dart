import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Warna-warna sesuai request
  static const Color bgColor = Color(0xFFFFFFFF);
  static const Color primaryBlue = Color(0xFF3B4287);
  static const Color textDarkBlue = Color(0xFF2A2E5E);
  static const Color textDarkGray = Color(0xFF2C2C2C);

  // FUNGSI MODAL DIHAPUS DARI SINI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 120),
                      _buildLogoRow(),
                      const SizedBox(height: 60),
                      _buildButtons(context),
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

  Widget _buildLogoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo/logo_kemenkum.png',
          width: 50,
          height: 50,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.broken_image),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 1.5,
          height: 40,
          color: textDarkBlue.withOpacity(0.5),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Posbankum',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: textDarkBlue,
                height: 1.1,
              ),
            ),
            Text(
              'Kanwil kemenkum Riau',
              style: TextStyle(
                fontSize: 12,
                color: textDarkBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        _AnimatedButton(
          onPressed: () {
            Get.toNamed(AppRoutes.LOGIN_FORM);
          },
          isPrimary: true,
          child: const Text('Masuk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 16),
        _AnimatedButton(
          onPressed: () {
            // ✅ BERUBAH: Langsung navigasi ke rute Register
            Get.toNamed(AppRoutes.REGISTER);
          },
          isPrimary: false,
          child: const Text('Daftar sebagai masyarakat', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildBottomIllustration() {
    return Image.asset(
      'assets/images/icons/logo_halaman_welcome.png',
      width: double.infinity,
      height: 160,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      errorBuilder: (c, e, s) => const SizedBox(height: 160),
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
          height: 52,
          decoration: BoxDecoration(
            color: widget.isPrimary ? LoginScreen.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: widget.isPrimary ? null : Border.all(color: LoginScreen.primaryBlue, width: 1.5),
            boxShadow: widget.isPrimary ? [
              BoxShadow(color: LoginScreen.primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
            ] : null,
          ),
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                color: widget.isPrimary ? Colors.white : LoginScreen.textDarkGray,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}