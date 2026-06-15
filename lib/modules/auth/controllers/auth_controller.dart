import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/data/services/api_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final _storage = GetStorage();
  
  var isLoading = false.obs;

  // --- FUNGSI LOGIN MANUAL (EMAIL & PASSWORD) ---
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['status'] == true) {
        _saveSessionAndRedirect(response.data['data']);
      } else {
        throw response.data['message'] ?? 'Login gagal.';
      }
    } catch (e) {
      _handleError('Gagal Login', e);
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI REGISTER MANUAL ---
  Future<void> register(String name, String email, String password, String confirmPassword) async {
    try {
      if (password != confirmPassword) throw 'Konfirmasi kata sandi tidak cocok.';
      
      isLoading.value = true;
      final response = await _apiService.dio.post('/register', data: {
        'nama_lengkap': name,
        'email': email,
        'password': password,
      });

      if (response.data['status'] == true) {
        _saveSessionAndRedirect(response.data['data']);
      } else {
        throw response.data['message'] ?? 'Registrasi gagal.';
      }
    } catch (e) {
      _handleError('Gagal Registrasi', e);
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI MASUK MENGGUNAKAN GOOGLE (SSO) ---
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      const webClientId = '544639004251-hpijg9mt4k9eqmj4hqetcae06ga64ooc.apps.googleusercontent.com';
      
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: webClientId,
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) throw 'Token ID Google tidak ditemukan.';

      final response = await _apiService.dio.post('/auth/google/callback', data: {
        'id_token': idToken,
      });

      if (response.data['status'] == true) {
        _saveSessionAndRedirect(response.data['data']);
      } else {
        throw response.data['message'] ?? 'Gagal otorisasi Google.';
      }
    } catch (e) {
      _handleError('Gagal Google Sign In', e);
    } finally {
      isLoading.value = false;
    }
  }

  void _saveSessionAndRedirect(Map<String, dynamic> data) async {
    final token = data['token'];
    final user = data['user'];
    final role = user['role'];

    await _storage.write('token', token);
    await _storage.write('user', user);
    await _storage.write('role', role);
    await _storage.write('is_logged_in', true);

    Get.snackbar('Berhasil', 'Selamat datang, ${user['nama_lengkap']}',
        backgroundColor: Colors.green, colorText: Colors.white);

    _redirectBasedOnRole(role);
  }

  // --- FUNGSI KELUAR (LOGOUT) ---
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _apiService.dio.post('/logout');
      await GoogleSignIn().signOut();
      await _storage.remove('token');
      await _storage.remove('user');
      await _storage.remove('role');
      await _storage.write('is_logged_in', false);

      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      await _storage.erase();
      Get.offAllNamed(AppRoutes.LOGIN);
    } finally {
      isLoading.value = false;
    }
  }

  void _redirectBasedOnRole(String role) {
    final String userRole = role.toLowerCase().trim();
    if (userRole == 'warga' || userRole == 'pelapor' || userRole == 'masyarakat') {
      Get.offAllNamed(AppRoutes.MAIN_DASHBOARD);
    } else if (userRole == 'paralegal' || userRole == 'admin' || userRole == 'posbankum') {
      Get.offAllNamed(AppRoutes.MAIN_DASHBOARD_ADMIN);
    } else {
      logout();
    }
  }

  void _handleError(String title, dynamic e) {
    String message = e.toString();
    if (e is String) message = e;
    Get.snackbar(title, message, backgroundColor: Colors.red, colorText: Colors.white);
  }
}
