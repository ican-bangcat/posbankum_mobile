import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ WAJIB IMPORT INI
import '../../../app/data/services/supabase_service.dart';
import '../../../app/routes/app_routes.dart';
import '../views/home_masyarakat_screen.dart';
import '../views/home_paralegal_screen.dart';

class AuthController extends GetxController {
  // 1. Inisialisasi Supabase Database Sendiri (Masyarakat/Paralegal)
  final supabase = Supabase.instance.client;

  // 🔥 2. Inisialisasi Supabase Database Tim Web (Posbankum)
  final webSupabase = SupabaseClient(
    dotenv.env['WEB_SUPABASE_URL']!,
    dotenv.env['WEB_SUPABASE_KEY']!,
  );

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;

  @override
  void onInit() {
    super.onInit();

    // DENGARKAN PERUBAHAN STATUS LOGIN (Deep Link & Auth State)
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      // KALAU USER KLIK LINK RESET PASSWORD DI EMAIL
      if (event == AuthChangeEvent.passwordRecovery) {
        Get.toNamed(AppRoutes.UPDATE_PASSWORD);
      }
    });
  }

  // --- FUNGSI TOGGLE MATA PASSWORD ---
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // --- 🔥 FUNGSI LOGIN MULTI-DATABASE (MAGIC HAPPENS HERE) ---
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email dan password wajib diisi',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // 🟢 SKENARIO 1: Coba login ke Database Sendiri (Masyarakat/Paralegal lokal)
      try {
        final AuthResponse res = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (res.user != null) {
          await _checkRoleAndRedirect(res.user!.id);
          return; // Sukses? Berhenti di sini.
        }
      } on AuthException catch (e) {
        // Kalau errornya BUKAN karena salah email/password, lempar errornya
        if (!e.message.toLowerCase().contains('invalid')) {
          rethrow;
        }
        // Kalau errornya Invalid Credentials, KITA JANGAN NYERAH. Lanjut Skenario 2!
      }

// 🔵 SKENARIO 2: Coba login ke Database Web (Posbankum)
      try {
        // ✅ 1. Pakai WebSupabaseService
        final AuthResponse webRes = await WebSupabaseService.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (webRes.user != null) {
          // ✅ 2. Ambil nama posbankum dari database web
          final dataPosbankum = await WebSupabaseService.client
              .from('posbankum')
              .select('nama')
              .eq('id_posbankum', webRes.user!.id)
              .maybeSingle();

          // Kalau namanya ada, pakai itu. Kalau kosong, panggil 'Posbankum'
          String namaPosbankum = dataPosbankum != null ? dataPosbankum['nama'] : 'Posbankum';

          // ✅ 3. Tampilkan pesan dengan nama dinamis
          Get.snackbar('Selamat Datang', 'Berhasil login sebagai $namaPosbankum',
              backgroundColor: Colors.green, colorText: Colors.white);

          // Langsung arahin ke Dashboard Admin
          Get.offAllNamed(AppRoutes.MAIN_DASHBOARD_ADMIN);
          return;
        }
      } on AuthException {
        // Kalau di db web juga salah, baru kita tolak mentah-mentah
        throw const AuthException('Email atau password salah!');
      }

    } on AuthException catch (e) {
      Get.snackbar('Gagal Login', e.message,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      print("Error Login: $e");
      Get.snackbar('Error', 'Terjadi kesalahan sistem',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI LOGIN WITH GOOGLE (Khusus Masyarakat DB Sendiri) ---
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

      if (idToken == null) throw 'No ID Token found.';

      final AuthResponse res = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (res.user != null) {
        final user = res.user!;

        final existingMasyarakat = await supabase
            .from('masyarakat')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        final existingParalegal = await supabase
            .from('paralegal')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (existingMasyarakat == null && existingParalegal == null) {
          final String namaGoogle = user.userMetadata?['full_name'] ?? 'Warga Baru';

          await supabase.from('masyarakat').insert({
            'id': user.id,
            'nama': namaGoogle,
            'created_at': DateTime.now().toIso8601String(),
          });

          Get.snackbar('Selamat Datang', 'Akun berhasil dibuat otomatis!',
              backgroundColor: Colors.green, colorText: Colors.white);
        }

        await _checkRoleAndRedirect(user.id);
      }

    } catch (e) {
      Get.snackbar('Error', 'Gagal Login Google: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
      print("Google Sign In Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI REGISTER EMAIL/PASSWORD (Khusus Masyarakat DB Sendiri) ---
  Future<void> register(String name, String email, String password, String confirmPassword) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Semua field harus diisi',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('Error', 'Password konfirmasi tidak sama',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        await supabase.from('masyarakat').insert({
          'id': res.user!.id,
          'nama': name,
          'created_at': DateTime.now().toIso8601String(),
        });

        Get.snackbar(
          'Berhasil', 'Akun berhasil dibuat! Silakan Login.',
          backgroundColor: Colors.green, colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        await Future.delayed(const Duration(milliseconds: 1500));
        Get.offAllNamed(AppRoutes.LOGIN_FORM);
      }
    } on AuthException catch (e) {
      Get.snackbar('Gagal Daftar', e.message,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // --- HELPER: CEK ROLE LOKAL & REDIRECT ---
  Future<void> _checkRoleAndRedirect(String userId) async {
    final masyarakatData = await supabase
        .from('masyarakat')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (masyarakatData != null) {
      Get.offAllNamed(AppRoutes.MAIN_DASHBOARD);
      return;
    }

    final paralegalData = await supabase
        .from('paralegal')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (paralegalData != null) {
      Get.offAllNamed(AppRoutes.MAIN_DASHBOARD_ADMIN);
      return;
    }

    Get.snackbar('Akses Ditolak', 'Data profil anda tidak ditemukan.',
        backgroundColor: Colors.orange, colorText: Colors.white);
    await supabase.auth.signOut();
  }
}