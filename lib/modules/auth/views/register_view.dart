import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final authC = Get.find<AuthController>();

  static const Color darkBlueColor = Color(0xFF2A2E5E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlueColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Section: Back Button & Title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  const Text(
                    'Kembali',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              
              // Center Section: Logo & Text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogoRow(),
                  const SizedBox(height: 48),
                  const Text(
                    'Buat Akun Baru',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Silakan daftar menggunakan akun Google Anda untuk mengajukan permohonan bantuan hukum secara gratis.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                    ),
                  ),
                ],
              ),

              // Bottom Section: Google Button & Footer
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: Obx(() {
                      final isLoading = authC.isLoading.value;
                      return ElevatedButton(
                        onPressed: isLoading ? null : () => authC.loginWithGoogle(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          disabledBackgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: darkBlueColor,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/icons/google.png',
                                    height: 22,
                                    errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata, color: Colors.blue),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Daftar dengan Google',
                                    style: TextStyle(
                                      color: darkBlueColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Kanwil Kemenkumham Riau',
                    style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoRow() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset('assets/images/logo/logo_kemenkum.png', width: 56, height: 56),
      const SizedBox(width: 16),
      Container(width: 1.5, height: 44, color: Colors.white30),
      const SizedBox(width: 16),
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Posbankum', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('Bantuan Hukum Gratis', style: TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    ],
  );
}
