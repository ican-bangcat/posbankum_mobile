import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../controllers/auth_controller.dart'; // ✅ 1. Import Controller
import 'register_modal.dart'; // ✅ 2. Import Register Modal
import '../../../app/routes/app_routes.dart';

/// Login Form Screen - Clean Design (No Animation Errors)
class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  // ✅ 3. Panggil Controller Biar Bisa Login
  final authC = Get.put(AuthController());

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi Buka Modal Register
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

                    // Logo BESAR di kiri - Bisa di klik buat BACK
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: _buildLogoHeader(),
                    ),

                    const SizedBox(height: 40),

                    // Selamat Datang
                    const Text(
                      'Selamat Datang',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Masuk untuk melanjutkan',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Input Email (Tetap)
                          _buildEmailField(),

                          const SizedBox(height: 16),

                          // 2. Input Password (Tetap)
                          _buildPasswordField(),

                          const SizedBox(height: 8),

                          // 3. Tombol Lupa Password (YANG DIUBAH) 👇
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // ❌ DULU: Pakai Get.defaultDialog (Pop-up)

                                // ✅ SEKARANG: Pindah ke Halaman Baru
                                Get.toNamed(AppRoutes.FORGOT_PASSWORD);
                              },
                              child: const Text(
                                'Lupa kata sandi?',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 4. Tombol Login (Tetap)
                          _buildLoginButton(),

                          const SizedBox(height: 16),

                          // 5. Tombol Google (Tetap)
                          _buildGoogleButton(),

                          const SizedBox(height: 24),

                          // 6. Link Daftar (Tetap)
                          _buildRegisterLink(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomIllustration(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Image.asset(
      'assets/images/logo/logo_posbankum.png',
      width: 80,
      height: 80,
      fit: BoxFit.contain,
      errorBuilder: (c, e, s) => Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.shield, color: Colors.white, size: 40),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Email wajib diisi' : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Kata Sandi',
        hintText: 'Kata Sandi',
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Password wajib diisi' : null,
    );
  }

  // ✅ WIDGET BUTTON LOGIN (UPDATE BIAR KONEK CONTROLLER)
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Obx(() => ElevatedButton( // Pake Obx buat Loading State
        onPressed: authC.isLoading.value
            ? null
            : () {
          if (_formKey.currentState!.validate()) {
            // Panggil Fungsi Login di Controller
            authC.login(
                _emailController.text,
                _passwordController.text
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: authC.isLoading.value
            ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
        )
            : const Text(
          'Masuk',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      )),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {
          Get.snackbar("Info", "Login Google menyusul!");
        },
        icon: const Icon(Icons.g_mobiledata, size: 24, color: AppColors.textPrimary),
        label: const Text(
          'Masuk via Google',
          style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Belum punya akun? ',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: _showRegisterModal, // ✅ Sudah benar membuka Modal
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Mari daftar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomIllustration() {
    return Image.asset(
      'assets/images/icons/building_illustration2.png',
      width: double.infinity,
      height: 140,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => Container(
        height: 140,
        color: Colors.white.withValues(alpha: 0.5),
      ),
    );
  }
}