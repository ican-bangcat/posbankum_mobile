import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../app/routes/app_routes.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final authC = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  static const Color darkBlueColor = Color(0xFF2A2E5E);
  static const Color yellowAccent = Color(0xFFFDEF0C);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final double bottomNavBarPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogoRow(),
                    const SizedBox(height: 20),
                    const Text('Buat Akun Baru', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textDark)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
                decoration: const BoxDecoration(
                  color: darkBlueColor,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Nama Lengkap'),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration('Nama Lengkap', Icons.person_outline),
                        validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Email'),
                      TextFormField(
                        controller: _emailController,
                        decoration: _inputDecoration('Email', Icons.email_outlined),
                        validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Kata Sandi'),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration('Kata Sandi', Icons.lock_outline),
                        validator: (v) => v!.isEmpty ? 'Kata sandi wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Konfirmasi Kata Sandi'),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration('Konfirmasi', Icons.lock_outline),
                        validator: (v) => v!.isEmpty ? 'Konfirmasi wajib diisi' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Obx(() => ElevatedButton(
                          onPressed: authC.isLoading.value ? null : () {
                            if (_formKey.currentState!.validate()) {
                              authC.register(_nameController.text, _emailController.text, _passwordController.text, _confirmPasswordController.text);
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: authC.isLoading.value ? const CircularProgressIndicator() : const Text('Daftar', style: TextStyle(color: darkBlueColor, fontWeight: FontWeight.bold)),
                        )),
                      ),
                      const SizedBox(height: 16),
                      const Center(child: Text('ATAU', style: TextStyle(color: Colors.white70, fontSize: 12))),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Obx(() => ElevatedButton.icon(
                          onPressed: authC.isLoading.value ? null : () => authC.loginWithGoogle(),
                          icon: Image.asset('assets/images/icons/google.png', height: 20, errorBuilder: (c,e,s) => const Icon(Icons.g_mobiledata)),
                          label: const Text('Daftar dengan Google', style: TextStyle(color: textLight)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        )),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: const Text.rich(TextSpan(style: TextStyle(color: Colors.white, fontSize: 13), children: [
                            TextSpan(text: 'Sudah punya akun? '),
                            TextSpan(text: 'Masuk', style: TextStyle(fontWeight: FontWeight.bold, color: yellowAccent)),
                          ])),
                        ),
                      ),
                      SizedBox(height: bottomNavBarPadding),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)));
  InputDecoration _inputDecoration(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
  );
  Widget _buildLogoRow() => Row(children: [
    Image.asset('assets/images/logo/logo_kemenkum.png', width: 44, height: 44),
    const SizedBox(width: 12),
    Container(width: 1.5, height: 36, color: darkBlueColor),
    const SizedBox(width: 12),
    const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Posbankum', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: darkBlueColor)),
      Text('Kanwil kemenkum Riau', style: TextStyle(fontSize: 12, color: textLight)),
    ]),
  ]);
}
