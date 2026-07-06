import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final authC = Get.find<AuthController>();

  // Palette warna sesuai gambar mockup
  static const Color primaryNavy = Color(0xFF1E2554);
  static const Color buttonNavy = Color(0xFF282C5E);
  static const Color bgLight = Color(0xFFF5F7FB);
  static const Color textGray = Color(0xFF64748B);
  static const Color textLightGray = Color(0xFF94A3B8);
  static const Color goldAccent = Color(0xFFD97706);
  static const Color goldBg = Color(0xFFFEF6E4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top & Center Sections
                          Column(
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 24),
                              _buildCenterIllustration(),
                              const SizedBox(height: 24),
                              _buildTextSection(),
                              const SizedBox(height: 24),
                            ],
                          ),
                          
                          // Bottom Section (White Sheet)
                          _buildBottomSheet(context),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo/logo_kemenkum.png',
            height: 48,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Container(
            width: 1.5,
            height: 32,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Posbankum',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: primaryNavy,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Kanwil kemenkumham Riau',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenterIllustration() {
    return Image.asset(
      'assets/images/logo/image_page_login.png',
      height: 200,
      fit: BoxFit.contain,
    );
  }

  Widget _buildTextSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bantuan Hukum Gratis Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: goldBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFBE8C3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: goldAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'BANTUAN HUKUM GRATIS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: goldAccent,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Keadilan untuk\nSetiap Warga Riau',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: primaryNavy,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Layanan pendampingan hukum resmi dari Kemenkumham, mudah diakses kapan saja.',
            style: TextStyle(
              fontSize: 14,
              color: textGray,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Google Sign-In Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Obx(() {
              final isLoading = authC.isLoading.value;
              return ElevatedButton(
                onPressed: isLoading ? null : () => authC.loginWithGoogle(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonNavy,
                  disabledBackgroundColor: buttonNavy.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                  shadowColor: Colors.black26,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SvgPicture.asset(
                              'assets/images/icons/google.svg',
                              height: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Masuk dengan Google',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              );
            }),
          ),
          const SizedBox(height: 12),
          
          // Terenkripsi & aman
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.check_circle_outline,
                size: 14,
                color: Colors.green,
              ),
              SizedBox(width: 6),
              Text(
                'Terenkripsi & aman',
                style: TextStyle(
                  fontSize: 12,
                  color: textGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey.shade200,
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'ATAU',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: textLightGray,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey.shade200,
                  thickness: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Register Promotion Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE2ECFF),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Belum punya akun?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Daftar sekarang, gratis',
                        style: TextStyle(
                          fontSize: 12,
                          color: textGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.REGISTER),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAB308),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Footer
          Text(
            '© 2026 Team Posbankum · All rights reserved',
            style: TextStyle(
              color: textLightGray,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
