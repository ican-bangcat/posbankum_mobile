import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';
import '../repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final GetStorage _storage;

  /// Jika true, skip snackbar & navigation (untuk unit testing).
  final bool testMode;
  
  var isLoading = false.obs;

  AuthController({
    AuthRepository? authRepository,
    GetStorage? storage,
    this.testMode = false,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _storage = storage ?? GetStorage();

  // --- FUNGSI LOGIN MANUAL (EMAIL & PASSWORD) ---
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final data = await _authRepository.loginManual(email, password);
      await saveSession(data);
      if (!testMode) _showSuccessAndRedirect(data);
    } catch (e) {
      if (!testMode) _handleError('Gagal Login', e);
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI REGISTER MANUAL ---
  Future<void> register(String name, String email, String password, String confirmPassword) async {
    try {
      if (password != confirmPassword) throw 'Konfirmasi kata sandi tidak cocok.';
      
      isLoading.value = true;
      final data = await _authRepository.registerManual(name, email, password);
      await saveSession(data);
      if (!testMode) _showSuccessAndRedirect(data);
    } catch (e) {
      if (!testMode) _handleError('Gagal Registrasi', e);
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

      final data = await _authRepository.loginWithGoogle(idToken);
      await saveSession(data);
      if (!testMode) _showSuccessAndRedirect(data);
    } catch (e) {
      if (!testMode) _handleError('Gagal Google Sign In', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Simpan data sesi ke storage lokal.
  Future<void> saveSession(Map<String, dynamic> data) async {
    final token = data['token'];
    final user = data['user'];
    final role = user['role'];

    await _storage.write('token', token);
    await _storage.write('user', user);
    await _storage.write('role', role);
    await _storage.write('is_logged_in', true);
  }

  /// Tampilkan snackbar sukses dan redirect berdasarkan role.
  void _showSuccessAndRedirect(Map<String, dynamic> data) {
    final user = data['user'];
    final role = user['role'];

    Get.snackbar('Berhasil', 'Selamat datang, ${user['nama_lengkap']}',
        backgroundColor: Colors.green, colorText: Colors.white);

    _redirectBasedOnRole(role);
  }

  // --- FUNGSI KELUAR (LOGOUT) ---
  Future<void> logout() async {
    try {
      isLoading.value = true;
      
      // Post logout to Laravel backend
      await _authRepository.logout();
      
      // Disconnect from Google Sign-In to force the account chooser next time
      try {
        await GoogleSignIn().disconnect();
      } catch (_) {
        try {
          await GoogleSignIn().signOut();
        } catch (_) {}
      }

      await clearSession();

      if (!testMode) Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      await _storage.erase();
      if (!testMode) Get.offAllNamed(AppRoutes.LOGIN);
    } finally {
      isLoading.value = false;
    }
  }

  /// Hapus data sesi dari storage lokal.
  Future<void> clearSession() async {
    await _storage.remove('token');
    await _storage.remove('user');
    await _storage.remove('role');
    await _storage.write('is_logged_in', false);
  }

  void _redirectBasedOnRole(String role) {
    final String userRole = role.toLowerCase().trim();
    if (userRole == 'warga' || userRole == 'pelapor' || userRole == 'masyarakat') {
      Get.offAllNamed(AppRoutes.WARGA_DASHBOARD);
    } else if (userRole == 'paralegal' || userRole == 'admin' || userRole == 'posbankum') {
      Get.offAllNamed(AppRoutes.PARALEGAL_DASHBOARD);
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
