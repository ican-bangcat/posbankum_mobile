import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  static const Color darkBlueColor = Color(0xFF2A2E5E);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.isSuccess.value) {
            return _buildSuccessState(context, controller);
          }
          return _buildFormState(context, controller);
        }),
      ),
    );
  }

  Widget _buildFormState(
      BuildContext context, ForgotPasswordController controller) {
    return LayoutBuilder(
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
                  // 1. CUSTOM HEADER
                  // ════════════════════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
                          onPressed: () => Get.back(),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Reset password',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // ════════════════════════════════════════════════════
                  // 2. KONTEN FORM
                  // ════════════════════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Silakan masukkan alamat email Anda.\nKami akan mengirimkan tautan untuk mereset kata sandi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: textLight, height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 32),

                        const Text(
                          'Email',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark),
                        ),
                        const SizedBox(height: 8),

                        TextField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 14, color: textDark),
                          decoration: InputDecoration(
                            hintText: 'contoh@email.com',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: darkBlueColor, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Obx(() => SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.sendResetLink(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkBlueColor,
                              disabledBackgroundColor: darkBlueColor.withOpacity(0.6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                              height: 22, width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Text(
                              'Kirim',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),

                  // ════════════════════════════════════════════════════
                  // 3. SPACER + ILUSTRASI BAWAH
                  // ════════════════════════════════════════════════════
                  const Spacer(),
                  SizedBox(
                    height: (MediaQuery.of(context).size.height * 0.26).clamp(160.0, 260.0),
                    child: Image.asset(
                      'assets/images/icons/ilustrasi_halaman_reset_password.png',
                      width: double.infinity,
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (c, e, s) => const SizedBox(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // STATE SUKSES - SESUAI DESAIN BARU
  // ════════════════════════════════════════════════════════════════════
  Widget _buildSuccessState(
      BuildContext context, ForgotPasswordController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Custom header
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
                onPressed: () => Get.back(),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Reset password',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),

        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- GAMBAR IKON BARU ---
                  Image.asset(
                    'assets/images/icons/icon_reset_password.png',
                    height: 100, // Disesuaikan proporsinya
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.mark_email_unread_rounded,
                      size: 80,
                      color: darkBlueColor,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- TEKS FORMAL & RAPI ---
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: textDark,
                        height: 1.6,
                      ),
                      children: [
                        const TextSpan(text: 'Tautan untuk mereset kata sandi telah dikirim ke\n'),
                        TextSpan(
                          text: controller.emailController.text,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: '.\nSilakan periksa kotak masuk Anda dan ikuti instruksi di dalamnya.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- TOMBOL KEMBALI (BIRU SOLID) ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Get.back(), // Fungsi kembali ke form login
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBlueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Kembali ke Halaman Masuk',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // --- ILUSTRASI BAWAH ---
        SizedBox(
          height: (MediaQuery.of(context).size.height * 0.26).clamp(160.0, 260.0),
          child: Image.asset(
            'assets/images/icons/ilustrasi_halaman_reset_password.png',
            width: double.infinity,
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            errorBuilder: (c, e, s) => const SizedBox(),
          ),
        ),
      ],
    );
  }
}