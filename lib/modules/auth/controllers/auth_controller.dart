import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';

/// Auth Controller - Handle login & register
class AuthController extends GetxController {
  final storage = GetStorage();
  
  // Observable variables
  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }
  
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Email dan password tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isLoading.value = true;
    
    // Simulasi API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Save to storage
    await storage.write('is_logged_in', true);
    await storage.write('user_email', email);
    
    isLoading.value = false;
    
    Get.snackbar(
      'Berhasil',
      'Login berhasil!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    
    // TODO: Navigate to home (sementara ke login lagi)
    Get.offAllNamed(AppRoutes.LOGIN);
  }
  
  Future<void> register(String name, String email, String password, String confirmPassword) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua field harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    if (password != confirmPassword) {
      Get.snackbar(
        'Error',
        'Password tidak sama',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isLoading.value = true;
    
    // Simulasi API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Save to storage
    await storage.write('is_logged_in', true);
    await storage.write('user_name', name);
    await storage.write('user_email', email);
    
    isLoading.value = false;
    
    Get.snackbar(
      'Berhasil',
      'Registrasi berhasil!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    
    // TODO: Navigate to home (sementara ke login lagi)
    Get.offAllNamed(AppRoutes.LOGIN);
  }
  
  Future<void> loginWithGoogle() async {
    Get.snackbar(
      'Info',
      'Google Sign In akan diimplementasikan nanti',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}