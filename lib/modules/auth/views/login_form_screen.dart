import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../controllers/auth_controller.dart';
import 'register_modal.dart';
import '../../../app/routes/app_routes.dart';

class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  // Panggil Controller
  final authC = Get.put(AuthController());

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variabel lokal untuk mata password
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showRegisterModal() {
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Header Logo
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Image.asset(
                        'assets/images/logo/logo_posbankum.png',
                        width: 80, height: 80, fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(Icons.shield, size: 80, color: AppColors.primary),
                      ),
                    ),

                    const SizedBox(height: 40),

                    const Text('Selamat Datang',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Masuk untuk melanjutkan',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),

                    const SizedBox(height: 40),

                    // FORM LOGIN
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration('Email', Icons.email_outlined),
                            validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
                          ),

                          const SizedBox(height: 16),

                          // 2. Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: _inputDecoration('Kata Sandi', Icons.lock_outline).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) => v!.isEmpty ? 'Password wajib diisi' : null,
                          ),

                          const SizedBox(height: 8),

                          // 3. Tombol Lupa Password (NAVIGASI BARU)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Get.toNamed(AppRoutes.FORGOT_PASSWORD),
                              child: const Text('Lupa kata sandi?',
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 4. Tombol Login (Pake Obx buat Loading)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: Obx(() => ElevatedButton(
                              onPressed: authC.isLoading.value ? null : () {
                                if (_formKey.currentState!.validate()) {
                                  authC.login(_emailController.text, _passwordController.text);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: authC.isLoading.value
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                                  : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                            )),
                          ),

                          const SizedBox(height: 16),

                          // 5. Tombol Google (SUDAH AKTIF)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: () => authC.loginWithGoogle(), // 👈 Panggil Fungsi Google
                              icon: Image.asset('assets/images/icons/google.png', height: 24,
                                  errorBuilder: (c,e,s)=> const Icon(Icons.g_mobiledata)),
                              label: const Text('Masuk via Google', style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.grey[300]!),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 6. Link Daftar
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Belum punya akun? ', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                                TextButton(
                                  onPressed: _showRegisterModal,
                                  child: const Text('Mari daftar', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Ilustrasi Bawah
            Image.asset(
              'assets/images/icons/building_illustration2.png',
              width: double.infinity, height: 140, fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const SizedBox(height: 50),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Style Input Biar Rapi
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    );
  }
}