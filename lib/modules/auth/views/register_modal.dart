import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../controllers/auth_controller.dart'; // Pastikan import ini benar

class RegisterModal extends StatefulWidget {
  const RegisterModal({super.key});

  @override
  State<RegisterModal> createState() => _RegisterModalState();
}

class _RegisterModalState extends State<RegisterModal> {
  // 1. Panggil Controller agar bisa dipakai
  final authC = Get.put(AuthController());

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          _buildHeader(),

          // Form Area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Title
                      const Text(
                        'Buat Akun Baru',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Isi data berikut untuk mendaftar',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Nama Lengkap
                      _buildTextField(
                        label: 'Nama Lengkap',
                        hint: 'Nama lengkap Anda',
                        icon: Icons.person_outline,
                        controller: _nameController,
                      ),

                      const SizedBox(height: 16),

                      // Email
                      _buildTextField(
                        label: 'Email',
                        hint: 'nama@email.com',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 16),

                      // Password
                      _buildTextField(
                        label: 'Kata Sandi',
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        isPassword: true,
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password
                      _buildTextField(
                        label: 'Konfirmasi Kata Sandi',
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        controller: _confirmPasswordController,
                        isPassword: true,
                      ),

                      const SizedBox(height: 24),

                      // Register Button (SUDAH TERHUBUNG LOGIC)
                      _buildRegisterButton(),

                      const SizedBox(height: 16),

                      // Google Button
                      _buildGoogleButton(),

                      const SizedBox(height: 16),

                      // Terms Checkbox
                      _buildTermsCheckbox(),

                      const SizedBox(height: 24),

                      // Login Link
                      _buildLoginLink(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Logo WHITE BESAR
          // Pastikan file assets/images/logo/logo_white.png ADA.
          // Kalau tidak ada, ganti path-nya sesuai file yang tersedia.
          Image.asset(
            'assets/images/logo/logo_white.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) => Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shield,
                color: AppColors.primary,
                size: 40,
              ),
            ),
          ),

          const Spacer(),

          // Close Button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && _obscurePassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            )
                : null,
            filled: true,
            fillColor: Colors.grey[50],
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
          validator: (v) => v == null || v.isEmpty ? '$label wajib diisi' : null,
        ),
      ],
    );
  }

  // --- BAGIAN INI YANG PALING PENTING (LOGIC SUPABASE) ---
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Obx(() => ElevatedButton(
        onPressed: authC.isLoading.value
            ? null
            : () async { // <--- TAMBAHKAN 'async' DISINI
          if (_formKey.currentState!.validate() && _agreeToTerms) {

            // 1. Panggil Register dan TUNGGU (await) sampai selesai
            await authC.register(
              _nameController.text,
              _emailController.text,
              _passwordController.text,
              _confirmPasswordController.text,
            );

            // 2. Cek: Kalau tidak loading lagi & tidak ada error, baru tutup
            // (Kita asumsikan kalau sukses, authC akan mengarahkan navigasi)

          } else if (!_agreeToTerms) {
            Get.snackbar(
              'Perhatian',
              'Anda harus menyetujui syarat & ketentuan',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        // Tampilkan Loading Spinner atau Teks
        child: authC.isLoading.value
            ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
        )
            : const Text(
          'Daftar',
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
          Get.snackbar('Info', 'Fitur Google Sign-In menyusul ya!');
        },
        icon: const Icon(Icons.g_mobiledata, size: 24, color: AppColors.textPrimary),
        label: const Text('Daftar via Google', style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
            activeColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              children: [
                TextSpan(text: 'Saya setuju dengan '),
                TextSpan(
                  text: 'syarat & ketentuan',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                TextSpan(text: ' yang berlaku'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Sudah punya akun? ',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Masuk',
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
}