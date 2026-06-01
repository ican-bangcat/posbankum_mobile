import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  // Menggunakan instance tunggal Supabase (Single Source of Truth)
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;

  // --- VARIABEL UNTUK MATH CAPTCHA ---
  var captchaNum1 = 0.obs;
  var captchaNum2 = 0.obs;
  var expectedCaptchaResult = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // Menginisialisasi soal captcha pertama kali
    generateCaptcha();

    // Memantau perubahan status autentikasi secara real-time
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.passwordRecovery) {
        Get.toNamed(AppRoutes.UPDATE_PASSWORD);
      }
      // 🚀 SOLUSI DOUBLE NOTIF: Menggunakan satu pintu gerbang redireksi otomatis ketika status terotentikasi
      else if (event == AuthChangeEvent.signedIn && session != null) {
        _checkRoleAndRedirect(session.user.id);
      }
    });
  }

  // --- FUNGSI GENERATE SOAL CAPTCHA ---
  void generateCaptcha() {
    final random = Random();
    captchaNum1.value = random.nextInt(10) + 1; // Angka acak 1-10
    captchaNum2.value = random.nextInt(10) + 1; // Angka acak 1-10
    expectedCaptchaResult.value = captchaNum1.value + captchaNum2.value;
  }

  // --- FUNGSI TOGGLE MATA PASSWORD ---
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // --- FUNGSI MASUK (LOGIN) DENGAN VALIDASI CAPTCHA ---
  Future<void> login(String email, String password, String userCaptchaAnswer) async {
    final String cleanEmail = email.trim();
    final String cleanPassword = password.trim();
    final String cleanCaptcha = userCaptchaAnswer.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty || cleanCaptcha.isEmpty) {
      Get.snackbar('Kesalahan', 'Alamat email, kata sandi, dan Captcha tidak boleh kosong',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // 🚀 VALIDASI CAPTCHA SEBELUM HIT LAYANAN SUPABASE AUTH
    if (cleanCaptcha != expectedCaptchaResult.value.toString()) {
      Get.snackbar('Otentikasi Gagal', 'Jawaban Captcha tidak tepat. Silakan coba lagi.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      generateCaptcha(); // Perbarui soal jika salah
      return;
    }

    try {
      isLoading.value = true;

      // Melakukan autentikasi kredensial ke layanan Supabase Auth
      await supabase.auth.signInWithPassword(
        email: cleanEmail,
        password: cleanPassword,
      );

      // 🚀 CATATAN: _checkRoleAndRedirect() di sini sengaja dihapus agar tidak bentrok
      // dengan listener stream di onInit (Menghilangkan bug double popup)

    } on AuthException catch (e) {
      generateCaptcha(); // Perbarui soal jika gagal masuk
      Get.snackbar('Gagal Autentikasi', e.message,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      generateCaptcha();
      debugPrint("Kesalahan Sistem Login: $e");
      Get.snackbar('Kesalahan Sistem', 'Terjadi kendala pada peladen. Silakan coba kembali.',
          backgroundColor: Colors.red, colorText: Colors.white);
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
      final googleAuth = await googleUser?.authentication;

      if (googleAuth == null) {
        isLoading.value = false;
        return;
      }

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw 'Token ID tidak ditemukan dalam respons kredensial Google.';

      final AuthResponse res = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (res.user != null) {
        final user = res.user!;
        final existingProfile = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (existingProfile == null) {
          final String namaGoogle = user.userMetadata?['full_name'] ?? 'Pengguna Baru';
          await supabase.from('profiles').insert({
            'id': user.id,
            'full_name': namaGoogle,
            'role': 'pelapor', // Konsisten menggunakan entitas pelapor
          });
          await supabase.from('masyarakat').insert({
            'id': user.id,
          });
          Get.snackbar('Pendaftaran Berhasil', 'Akun berhasil dibuat secara otomatis melalui Google.',
              backgroundColor: Colors.green, colorText: Colors.white);
        }
        await _checkRoleAndRedirect(user.id);
      }
    } catch (e) {
      Get.snackbar('Gagal Autentikasi SSO', 'Kegagalan otorisasi Google: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
      debugPrint("Kesalahan Google Sign In: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI PENDAFTARAN PENGGUNA BARU (REGISTRASI) ---
  Future<void> register(String name, String email, String password, String confirmPassword, String userCaptchaAnswer) async {
    final String cleanName = name.trim();
    final String cleanEmail = email.replaceAll(RegExp(r'\s+'), '').replaceAll(RegExp(r'\u200B'), '').trim();
    final String cleanPassword = password.replaceAll(RegExp(r'\s+'), '').trim();
    final String cleanConfirm = confirmPassword.replaceAll(RegExp(r'\s+'), '').trim();
    final String cleanCaptcha = userCaptchaAnswer.trim();

    if (cleanName.isEmpty || cleanEmail.isEmpty || cleanPassword.isEmpty || cleanCaptcha.isEmpty) {
      Get.snackbar('Validasi Gagal', 'Seluruh kolom isian termasuk Captcha wajib dilengkapi',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Validasi Captcha
    if (cleanCaptcha != expectedCaptchaResult.value.toString()) {
      Get.snackbar('Otentikasi Gagal', 'Jawaban Captcha tidak tepat. Silakan coba lagi.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      generateCaptcha(); // Perbarui soal jika salah
      return;
    }

    if (cleanPassword != cleanConfirm) {
      Get.snackbar('Validasi Gagal', 'Kata sandi konfirmasi tidak selaras',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (cleanPassword.length < 8) {
      Get.snackbar('Validasi Gagal', 'Kata sandi harus terdiri dari minimal 8 karakter',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('🔵 [INFO] Memulai proses registrasi untuk email: $cleanEmail');

      final AuthResponse res = await supabase.auth.signUp(
        email: cleanEmail,
        password: cleanPassword,
        // 🚀 DATA METADATA MANDATORI UNTUK DIBACA TRIGGERS DATABASE POSTGRESQL
        data: {
          'full_name': cleanName,
          'role': 'pelapor',
        },
        emailRedirectTo: 'io.posbankum.app://login-callback',
      );

      if (res.user != null) {
        debugPrint('✅ [SUCCESS] Kredensial berhasil dibuat. Database Trigger akan memproses tabel profiles.');

        // Memperbarui soal Captcha untuk mengantisipasi sesi berikutnya
        generateCaptcha();

        Get.snackbar(
          'Pendaftaran Berhasil', 'Silakan cek kotak masuk Email Anda untuk verifikasi sebelum Login.',
          backgroundColor: Colors.green, colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );

        await Future.delayed(const Duration(milliseconds: 2000));
        Get.offAllNamed(AppRoutes.LOGIN_FORM);
      }
    } on AuthException catch (e) {
      debugPrint('❌ [ERROR LOG] Gagal mendaftar: ${e.message}');
      Get.snackbar('Pendaftaran Ditolak', e.message,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI VALIDASI PERAN (ROLE) DAN PENGALIHAN RUTE ---
  Future<void> _checkRoleAndRedirect(String userId) async {
    try {
      final profileData = await supabase
          .from('profiles')
          .select('role, full_name, id_posbankum')
          .eq('id', userId)
          .maybeSingle();

      if (profileData != null) {
        // Tangkap role aslinya, lalu ubah ke huruf kecil semua biar kebal Case Sensitive
        final String rawRole = profileData['role']?.toString() ?? 'pelapor';
        final String userRole = rawRole.toLowerCase().trim();
        final String userName = profileData['full_name'] ?? 'Pengguna';

        debugPrint('🔵 [INFO DB] Role dari database: "$rawRole" -> Dibaca sistem: "$userRole"');

        // Akseptasi alur rute untuk tingkat kewenangan Pelapor / Masyarakat umum
        if (userRole == 'pelapor' || userRole == 'user' || userRole == 'masyarakat') {
          Get.snackbar('Otorisasi Berhasil', 'Selamat datang kembali, $userName',
              backgroundColor: Colors.green, colorText: Colors.white);
          Get.offAllNamed(AppRoutes.MAIN_DASHBOARD);
        } else if (userRole == 'posbankum' || userRole == 'admin') {
          Get.snackbar('Otorisasi Berhasil', 'Akses administrator diberikan kepada $userName',
              backgroundColor: Colors.green, colorText: Colors.white);
          Get.offAllNamed(AppRoutes.MAIN_DASHBOARD_ADMIN);
        } else {
          debugPrint('❌ [ERROR ROLE] Role "$userRole" tidak ada di logika percabangan!');
          Get.snackbar('Otorisasi Ditolak', 'Peran pengguna ($rawRole) tidak dikenali sistem.',
              backgroundColor: Colors.orange, colorText: Colors.white);
          await supabase.auth.signOut();
        }
      } else {
        Get.snackbar('Integritas Data Gagal', 'Data profil Anda tidak ditemukan dalam sistem.',
            backgroundColor: Colors.red, colorText: Colors.white);
        await supabase.auth.signOut();
      }
    } catch (e) {
      debugPrint('❌ [ERROR CHECK ROLE] $e');
      await supabase.auth.signOut();
    }
  }
}