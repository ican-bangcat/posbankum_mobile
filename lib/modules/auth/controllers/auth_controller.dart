import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../app/routes/app_routes.dart';
import '../views/home_masyarakat_screen.dart';
import '../views/home_paralegal_screen.dart';

class AuthController extends GetxController {
  // 1. Inisialisasi Supabase & Variabel Reactive
  final supabase = Supabase.instance.client;
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
        // ✅ SEKARANG: Pindah ke Halaman Update Password (Bukan Dialog lagi)
        Get.toNamed(AppRoutes.UPDATE_PASSWORD);
      }
    });
  }

  // --- FUNGSI TOGGLE MATA PASSWORD ---
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // --- FUNGSI LOGIN EMAIL/PASSWORD ---
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email dan password wajib diisi',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // 1. Login ke Auth Supabase
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // 2. Cek Role User (Masyarakat / Paralegal)
      if (res.user != null) {
        await _checkRoleAndRedirect(res.user!.id);
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

  // --- ✅ FUNGSI BARU: LOGIN WITH GOOGLE ---
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      // ⚠️ GANTI DENGAN WEB CLIENT ID DARI GOOGLE CLOUD (TIPE WEB) ⚠️
      const webClientId = '544639004251-hpijg9mt4k9eqmj4hqetcae06ga64ooc.apps.googleusercontent.com';

      // 1. Buka Pop-up Google Sign In Native

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: webClientId,       // ✅ TAMBAHKAN INI (Biar Web/Emulator ga bingung)
        serverClientId: webClientId, // ✅ INI TETAP ADA (Biar Supabase bisa baca tokennya)
      );

      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;

      // Kalau user batal milih akun
      if (googleAuth == null) {
        isLoading.value = false;
        return;
      }

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      // 2. Tukar Token Google dengan Session Supabase
      final AuthResponse res = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // 3. LOGIKA AUTO-REGISTER KE TABEL MASYARAKAT
      if (res.user != null) {
        final user = res.user!;

        // Cek apakah sudah ada di tabel masyarakat?
        final existingMasyarakat = await supabase
            .from('masyarakat')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        // Cek apakah sudah ada di tabel paralegal?
        final existingParalegal = await supabase
            .from('paralegal')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        // JIKA BELUM ADA DI KEDUANYA -> Berarti User Baru -> Masukkan ke Masyarakat
        if (existingMasyarakat == null && existingParalegal == null) {

          final String namaGoogle = user.userMetadata?['full_name'] ?? 'Warga Baru';
          final String emailGoogle = user.email ?? '';
          final String fotoGoogle = user.userMetadata?['avatar_url'] ?? '';

          // Insert ke tabel masyarakat
          // Pastikan kolom 'email' dan 'foto_profil' ada di tabel masyarakat kamu
          // Kalau belum ada kolomnya, hapus baris email & foto di bawah ini
          await supabase.from('masyarakat').insert({
            'id': user.id,
            'nama': namaGoogle,
            // 'email': emailGoogle, // Uncomment kalau ada kolom email
            // 'foto_profil': fotoGoogle, // Uncomment kalau ada kolom foto_profil
            'created_at': DateTime.now().toIso8601String(),
          });

          Get.snackbar('Selamat Datang', 'Akun berhasil dibuat otomatis!',
              backgroundColor: Colors.green, colorText: Colors.white);
        }

        // 4. Redirect sesuai Role
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

  // --- FUNGSI REGISTER EMAIL/PASSWORD ---
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

      // A. Daftar ke Supabase Auth
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      // B. Simpan Data Profil
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

  // --- HELPER: CEK ROLE & REDIRECT ---
  Future<void> _checkRoleAndRedirect(String userId) async {
    // 1. Cek Masyarakat
    final masyarakatData = await supabase
        .from('masyarakat')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (masyarakatData != null) {
      Get.offAllNamed(AppRoutes.MAIN_DASHBOARD); // Sesuaikan dengan route Home Masyarakat
      return;
    }

    // 2. Cek Paralegal
    final paralegalData = await supabase
        .from('paralegal')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (paralegalData != null) {
      // Asumsi route home paralegal belum didaftarkan di AppRoutes, pakai class langsung dulu
      Get.offAll(() => const HomeParalegalScreen());
      return;
    }

    // 3. Tidak Ketemu
    Get.snackbar('Akses Ditolak', 'Data profil anda tidak ditemukan.',
        backgroundColor: Colors.orange, colorText: Colors.white);
    await supabase.auth.signOut();
  }
}