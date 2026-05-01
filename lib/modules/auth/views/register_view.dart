import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../../../app/routes/app_routes.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final authC = Get.put(AuthController());

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  // --- Palet Warna ---
  static const Color darkBlueColor = Color(0xFF2A2E5E);
  static const Color yellowAccent = Color(0xFFFDEF0C);
  static const Color greenCheck = Color(0xFF22C55E);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFF64748B);

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ════════════════════════════════════════════════════
              // 1. BAGIAN HEADER (PUTIH)
              // ════════════════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogoRow(),
                    const SizedBox(height: 20),
                    const Text(
                      'Buat Akun Baru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Isi data berikut untuk mendaftar',
                      style: TextStyle(fontSize: 12, color: textLight),
                    ),
                  ],
                ),
              ),

              // ════════════════════════════════════════════════════
              // 2. BAGIAN FORM BIRU TUA + ILUSTRASI DI DALAMNYA
              // ════════════════════════════════════════════════════
              Container(
                decoration: const BoxDecoration(
                  color: darkBlueColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Stack(
                  children: [
                    // --- ILUSTRASI BACKGROUND BAWAH ---
                    Positioned(
                      bottom: 0, // Ditempelkan ke dasar container
                      right: 0,
                      left: 0,
                      child: IgnorePointer(
                        child: Image.asset(
                          'assets/images/icons/ilustrasi_halaman_register.png',
                          height: 140,
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                          errorBuilder: (c, e, s) => const SizedBox(),
                        ),
                      ),
                    ),

                    // --- FORM KONTEN ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- NAMA LENGKAP ---
                            _buildLabel('Nama Lengkap'),
                            _buildTextField(
                              hint: 'Nama lengkap',
                              icon: Icons.person_outline,
                              controller: _nameController,
                            ),
                            const SizedBox(height: 16),

                            // --- EMAIL ---
                            _buildLabel('Email Pemilik'),
                            _buildTextField(
                              hint: 'Email',
                              icon: Icons.email_outlined,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),

                            // --- KATA SANDI ---
                            _buildLabel('Kata Sandi'),
                            _buildTextField(
                              hint: '••••••••••••',
                              icon: Icons.lock_outline,
                              controller: _passwordController,
                              isPassword: true,
                              obscureValue: _obscurePassword,
                              onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            const SizedBox(height: 16),

                            // --- KONFIRMASI KATA SANDI ---
                            _buildLabel('Password'),
                            _buildTextField(
                              hint: '••••••••••••',
                              icon: Icons.lock_outline,
                              controller: _confirmPasswordController,
                              isPassword: true,
                              obscureValue: _obscureConfirmPassword,
                              onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                            const SizedBox(height: 24),

                            // --- TOMBOL DAFTAR ---
                            _buildRegisterButton(),
                            const SizedBox(height: 12),

                            // --- TOMBOL GOOGLE ---
                            _buildGoogleButton(),
                            const SizedBox(height: 20),

                            // --- CHECKBOX S&K ---
                            _buildTermsCheckbox(),

                            const SizedBox(height: 24),

                            // --- LINK LOGIN (Pindah ke atas ilustrasi) ---
                            _buildLoginLink(),

                            // Spacer agar ilustrasi di bawah punya ruang dan halaman bisa discroll mentok ke bawah
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HEADER LOGO ---
  Widget _buildLogoRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo/logo_kemenkum.png',
          width: 44,
          height: 44,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 44, height: 44, color: Colors.grey[200], child: const Icon(Icons.broken_image),
          ),
        ),
        const SizedBox(width: 12),
        Container(width: 1.5, height: 36, color: darkBlueColor),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Posbankum',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: darkBlueColor,
                height: 1.1,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Kanwil kemenkum Riau',
              style: TextStyle(fontSize: 12, color: textLight),
            ),
          ],
        ),
      ],
    );
  }

  // --- WIDGET HELPER TEXT & INPUT ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureValue = true,
    VoidCallback? onToggleObscure,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && obscureValue,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscureValue ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
            size: 18,
          ),
          onPressed: onToggleObscure,
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: yellowAccent, width: 1.5),
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Form wajib diisi' : null,
    );
  }

  // --- WIDGET TOMBOL ---
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Obx(() => ElevatedButton(
        onPressed: authC.isLoading.value
            ? null
            : () async {
          if (_formKey.currentState!.validate() && _agreeToTerms) {
            await authC.register(
              _nameController.text,
              _emailController.text,
              _passwordController.text,
              _confirmPasswordController.text,
            );
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: authC.isLoading.value
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(color: darkBlueColor, strokeWidth: 2.5),
        )
            : const Text(
          'Daftar',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
      )),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        // ✅ FUNGSI GOOGLE DIKEMBALIKAN
        onPressed: () => authC.loginWithGoogle(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          // 🔥 KODE INI YANG BIKIN LOGO & TEKS KE TENGAH
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/icons/google.png',
              height: 20,
              errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata, color: darkBlueColor, size: 24),
            ),
            const SizedBox(width: 14),
            const Text(
              'Daftar dengan Google',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600, // Sedikit ditebalkan biar mantap
                color: textLight, // Pakai warna abu-abu standar yang udah kita definisikan
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET LAINNYA ---
  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _agreeToTerms ? greenCheck : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: _agreeToTerms ? greenCheck : Colors.white,
                width: 1.5,
              ),
            ),
            child: _agreeToTerms
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: yellowAccent,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(text: 'Saya setuju dengan syarat & ketentuan\n'),
                TextSpan(text: 'yang berlaku'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'sudah punya akun? ',
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
          GestureDetector(
            onTap: () {
              Get.offNamed(AppRoutes.LOGIN_FORM);
            },
            child: const Text(
              'Masuk',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: yellowAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}