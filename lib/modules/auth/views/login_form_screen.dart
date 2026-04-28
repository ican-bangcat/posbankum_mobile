import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import 'register_modal.dart';

class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final authC = Get.put(AuthController());

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  // --- Palet Warna ---
  static const Color darkBlueColor = Color(0xFF2A2E5E);
  static const Color yellowAccent = Color(0xFFFDEF0C);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFF64748B);

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
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ════════════════════════════════════════════════════
                      // 1. BAGIAN HEADER (Logo + Teks Sapaan)
                      // ════════════════════════════════════════════════════
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 52, 32, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLogoRow(),
                            const SizedBox(height: 28),
                            const Text(
                              'Selamat Datang',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: textDark,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Masuk untuk melanjutkan',
                              style: TextStyle(fontSize: 15, color: textLight),
                            ),
                          ],
                        ),
                      ),

                      // ════════════════════════════════════════════════════
                      // 2. ILUSTRASI — RESPONSIVE DENGAN MEDIAQUERY + CLAMP
                      // ════════════════════════════════════════════════════
                      SizedBox(
                        height: (MediaQuery.of(context).size.height * 0.18).clamp(120.0, 200.0), // 🔥 FIX RESPONSIVE DI SINI
                        child: Image.asset(
                          'assets/images/icons/logo_halaman_login.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                          errorBuilder: (c, e, s) => const SizedBox(),
                        ),
                      ),

                      // ════════════════════════════════════════════════════
                      // 3. BAGIAN FORM BIRU TUA
                      // ════════════════════════════════════════════════════
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(28, 36, 28, 0),
                          decoration: const BoxDecoration(
                            color: darkBlueColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- INPUT EMAIL ---
                                const Text(
                                  'Email',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration:
                                  _inputDecoration('Email', Icons.email_outlined),
                                  validator: (v) =>
                                  v!.isEmpty ? 'Email wajib diisi' : null,
                                ),

                                const SizedBox(height: 20),

                                // --- INPUT KATA SANDI ---
                                const Text(
                                  'Kata Sandi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration:
                                  _inputDecoration('Kata Sandi', Icons.lock_outline)
                                      .copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(
                                              () => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  validator: (v) =>
                                  v!.isEmpty ? 'Kata sandi wajib diisi' : null,
                                ),

                                const SizedBox(height: 10),

                                // --- LUPA KATA SANDI ---
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () =>
                                        Get.toNamed(AppRoutes.FORGOT_PASSWORD),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(50, 30),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Lupa kata sandi?',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: yellowAccent,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // --- TOMBOL MASUK ---
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: Obx(() => ElevatedButton(
                                    onPressed: authC.isLoading.value
                                        ? null
                                        : () {
                                      if (_formKey.currentState!
                                          .validate()) {
                                        authC.login(
                                          _emailController.text,
                                          _passwordController.text,
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: authC.isLoading.value
                                        ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          color: darkBlueColor),
                                    )
                                        : const Text(
                                      'Masuk',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: darkBlueColor,
                                      ),
                                    ),
                                  )),
                                ),

                                const SizedBox(height: 12),

                                // --- TOMBOL GOOGLE ---
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton.icon(
                                    onPressed: () => authC.loginWithGoogle(),
                                    icon: Image.asset(
                                      'assets/images/icons/google.png',
                                      height: 22,
                                      errorBuilder: (c, e, s) => const Icon(
                                        Icons.g_mobiledata,
                                        color: darkBlueColor,
                                        size: 28,
                                      ),
                                    ),
                                    label: const Text(
                                      'Masuk dengan Google',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textLight,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),

                                const Spacer(),
                                const SizedBox(height: 20),

                                // --- LINK DAFTAR ---
                                Center(
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      const Text(
                                        'Belum punya akun? ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _showRegisterModal,
                                        child: const Text(
                                          'Daftar',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: yellowAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
          width: 52,
          height: 52,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 52,
            height: 52,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image),
          ),
        ),
        const SizedBox(width: 14),
        Container(width: 2, height: 40, color: darkBlueColor),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Posbankum',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: darkBlueColor,
                height: 1.1,
              ),
            ),
            Text(
              'Kanwil kemenkum Riau',
              style: TextStyle(fontSize: 13, color: textLight),
            ),
          ],
        ),
      ],
    );
  }

  // --- STYLING KOTAK INPUT ---
  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: yellowAccent, width: 2),
      ),
    );
  }
}