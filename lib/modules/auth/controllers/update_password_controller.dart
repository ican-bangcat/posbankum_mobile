import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdatePasswordController extends GetxController {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observable states
  final isLoading = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final errorMessage = ''.obs;

  final supabase = Supabase.instance.client;

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Validate passwords
  bool validatePasswords() {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Check if empty
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Password tidak boleh kosong',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    // Check minimum length
    if (newPassword.length < 6) {
      Get.snackbar(
        'Error',
        'Password minimal 6 karakter',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    // Check if passwords match
    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Error',
        'Password tidak sama',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    return true;
  }

  // Update password
  Future<void> updatePassword() async {
    if (!validatePasswords()) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final newPassword = newPasswordController.text;

      await supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );

      isLoading.value = false;

      // Show success message
      Get.snackbar(
        'Sukses',
        'Password berhasil diubah',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );

      // Wait a moment then navigate to login
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed('/login'); // Replace with your Routes.LOGIN

    } on AuthException catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Terjadi kesalahan. Silahkan coba lagi.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}