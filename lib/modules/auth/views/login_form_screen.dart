import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import 'register_modal.dart';

/// Login Form Screen - Clean Design (No Animation Errors)
class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
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
                    
                    // Logo BESAR di kiri - PURE LOGO
                    _buildLogoHeader(),
                    
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
                          _buildEmailField(),
                          const SizedBox(height: 16),
                          _buildPasswordField(),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Lupa kata sandi?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildLoginButton(),
                          const SizedBox(height: 16),
                          _buildGoogleButton(),
                          const SizedBox(height: 24),
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

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Get.snackbar('Success', 'Login berhasil!');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text(
          'Masuk',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {},
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
            onPressed: _showRegisterModal,
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