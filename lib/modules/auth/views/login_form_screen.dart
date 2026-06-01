import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

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
  final _captchaController = TextEditingController();

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
    _captchaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomNavBarPadding = MediaQuery.of(context).padding.bottom;

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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLogoRow(),
                            const SizedBox(height: 20),
                            const Text(
                              'Selamat Datang',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textDark, letterSpacing: -0.5),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Masuk untuk melanjutkan',
                              style: TextStyle(fontSize: 14, color: textLight),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: (MediaQuery.of(context).size.height * 0.15).clamp(100.0, 160.0),
                        child: Image.asset(
                          'assets/images/icons/logo_halaman_login.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                          errorBuilder: (c, e, s) => const SizedBox(),
                        ),
                      ),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
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
                                const Text('Email', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(color: textDark, fontSize: 14),
                                  decoration: _inputDecoration('Email', Icons.email_outlined),
                                  validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
                                ),

                                const SizedBox(height: 16),

                                const Text('Kata Sandi', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(color: textDark, fontSize: 14),
                                  decoration: _inputDecoration('Kata Sandi', Icons.lock_outline).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 18),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  validator: (v) => v!.isEmpty ? 'Kata sandi wajib diisi' : null,
                                ),

                                const SizedBox(height: 6),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => Get.toNamed(AppRoutes.FORGOT_PASSWORD),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(50, 30),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('Lupa kata sandi?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: yellowAccent)),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                const Text('Otentikasi (Captcha)', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                _buildCaptchaField(),

                                const SizedBox(height: 24),

                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: Obx(() => ElevatedButton(
                                    onPressed: authC.isLoading.value
                                        ? null
                                        : () {
                                      if (_formKey.currentState!.validate()) {
                                        authC.login(
                                          _emailController.text,
                                          _passwordController.text,
                                          _captchaController.text,
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                    ),
                                    child: authC.isLoading.value
                                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: darkBlueColor, strokeWidth: 2.5))
                                        : const Text('Masuk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: darkBlueColor)),
                                  )),
                                ),

                                const SizedBox(height: 12),

                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: () => authC.loginWithGoogle(),
                                    icon: Image.asset('assets/images/icons/google.png', height: 20, errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata, color: darkBlueColor, size: 24)),
                                    label: const Text('Masuk dengan Google', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textLight)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),

                                const Spacer(),
                                const SizedBox(height: 16),

                                Center(
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      const Text('Belum punya akun? ', style: TextStyle(fontSize: 13, color: Colors.white)),
                                      GestureDetector(
                                        onTap: () => Get.toNamed(AppRoutes.REGISTER),
                                        child: const Text('Daftar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: yellowAccent)),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 24 + bottomNavBarPadding),
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

  Widget _buildCaptchaField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => Text(
              'Berapa hasil dari ${authC.captchaNum1.value} + ${authC.captchaNum2.value} ?',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            )),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: _captchaController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark),
              decoration: InputDecoration(
                hintText: 'Hasil',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Wajib!' : null,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(color: yellowAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: yellowAccent, size: 20),
              onPressed: () {
                authC.generateCaptcha();
                _captchaController.clear();
              },
              tooltip: 'Ganti Soal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo/logo_kemenkum.png',
          width: 44, height: 44, fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(width: 44, height: 44, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
        ),
        const SizedBox(width: 12),
        Container(width: 1.5, height: 36, color: darkBlueColor),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Posbankum', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: darkBlueColor, height: 1.1)),
            Text('Kanwil kemenkum Riau', style: TextStyle(fontSize: 12, color: textLight)),
          ],
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: yellowAccent, width: 1.5)),
    );
  }
}