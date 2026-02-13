import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordController extends GetxController {
  // 1. Controller untuk Input Email
  final emailController = TextEditingController();

  // 2. State Management (Loading & Success)
  final isLoading = false.obs;
  final isSuccess = false.obs; // Kalau true, UI berubah jadi gambar amplop

  // 3. Supabase Client
  final supabase = Supabase.instance.client;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  // --- FUNGSI VALIDASI EMAIL ---
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // --- FUNGSI UTAMA: KIRIM LINK RESET ---
  Future<void> sendResetLink() async {
    final email = emailController.text.trim();

    // A. Validasi Input
    if (email.isEmpty) {
      Get.snackbar('Error', 'Email tidak boleh kosong',
          backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
      return;
    }

    if (!isValidEmail(email)) {
      Get.snackbar('Error', 'Format email tidak valid',
          backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
      return;
    }

    try {
      isLoading.value = true;

      // B. Kirim Request ke Supabase
      // PENTING: redirectTo harus sama persis dengan yang di AndroidManifest & Supabase Dashboard
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.posbankum.app://login-callback', // 👈 INI KUNCINYA!
      );

      // C. Sukses! Ubah Tampilan UI
      isSuccess.value = true;

    } on AuthException catch (e) {
      Get.snackbar('Gagal', e.message,
          backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan sistem. Coba lagi nanti.',
          backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
      print("Error Forgot Password: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI RESET STATE (Opsional) ---
  // Dipakai kalau user mau kembali ngisi ulang email (misal salah ketik)
  void resetState() {
    isSuccess.value = false;
    isLoading.value = false;
    emailController.clear();
  }
}