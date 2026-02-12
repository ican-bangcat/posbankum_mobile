import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/routes/app_routes.dart';
import '../views/home_masyarakat_screen.dart';
import '../views/home_paralegal_screen.dart';
class AuthController extends GetxController {
  // --- 1. INI YANG BIKIN MERAH KALAU HILANG ---
  // Kita kenalan dulu sama Supabase & Variabel Loading
  final supabase = Supabase.instance.client;
  var isLoading = false.obs;
  var isPasswordHidden = true.obs;

  @override
  void onInit() {
    super.onInit();

    // DENGARKAN PERUBAHAN STATUS LOGIN (Deep Link)
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      // KALAU USER KLIK LINK RESET PASSWORD DI EMAIL
      if (event == AuthChangeEvent.passwordRecovery) {
        _showUpdatePasswordDialog(); // Panggil Dialog
      }
    });
  }


  void _showUpdatePasswordDialog() {
    final newPassC = TextEditingController();

    Get.defaultDialog(
      title: "Password Baru",
      barrierDismissible: false,
      content: Column(
        children: [
          const Text("Silakan buat password baru Anda:"),
          const SizedBox(height: 10),
          TextField(
            controller: newPassC,
            obscureText: true,
            decoration: const InputDecoration(
                hintText: "Password Baru",
                border: OutlineInputBorder()
            ),
          ),
        ],
      ),
      textConfirm: "Simpan",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        if (newPassC.text.length < 6) {
          Get.snackbar("Error", "Password minimal 6 karakter");
          return;
        }

        try {
          // UPDATE PASSWORD DI SUPABASE
          await supabase.auth.updateUser(
            UserAttributes(password: newPassC.text),
          );

          Get.back(); // Tutup Dialog
          Get.snackbar("Sukses", "Password berhasil diubah! Silakan Login.",
              backgroundColor: Colors.green, colorText: Colors.white);

          // Arahkan ke Login
          Get.offAllNamed(AppRoutes.LOGIN);

        } catch (e) {
          Get.snackbar("Gagal", e.toString());
        }
      },
    );
  }
  // Fungsi toggle mata password
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // --- FUNGSI LOGIN UPDATE ---
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email dan password wajib diisi', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // 1. Login ke Auth Supabase
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        String userId = res.user!.id;

        // 2. CEK: Apakah dia Masyarakat?
        // Kita cari data di tabel masyarakat yang ID-nya sama dengan User ID
        final masyarakatData = await supabase
            .from('masyarakat')
            .select()
            .eq('id', userId)
            .maybeSingle(); // maybeSingle() aman kalau data tidak ditemukan (return null)

        if (masyarakatData != null) {
          // KETEMU! Dia Masyarakat
          Get.snackbar('Berhasil', 'Login sebagai Masyarakat', backgroundColor: Colors.blue, colorText: Colors.white);
          Get.offAll(() => const HomeMasyarakatScreen());
          return; // Stop disini
        }

        // 3. Kalau bukan Masyarakat, CEK: Apakah dia Paralegal?
        final paralegalData = await supabase
            .from('paralegal')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (paralegalData != null) {
          // KETEMU! Dia Paralegal
          Get.snackbar('Berhasil', 'Login sebagai Paralegal', backgroundColor: Colors.green, colorText: Colors.white);
          Get.offAll(() => const HomeParalegalScreen());
          return; // Stop disini
        }

        // 4. Kalau tidak ketemu di dua-duanya? (Kasus aneh/Admin belum input data)
        Get.snackbar('Akses Ditolak', 'Data profil anda tidak ditemukan. Hubungi Admin.', backgroundColor: Colors.orange, colorText: Colors.white);
        await supabase.auth.signOut(); // Logout paksa
      }
    } on AuthException catch (e) {
      Get.snackbar('Gagal Login', e.message, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      print("Error Login: $e");
      Get.snackbar('Error', 'Terjadi kesalahan sistem', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI REGISTER UPDATE ---
  Future<void> register(String name, String email, String password, String confirmPassword) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Semua field harus diisi', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('Error', 'Password konfirmasi tidak sama', backgroundColor: Colors.red, colorText: Colors.white);
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
        });

        // C. SUKSES!
        Get.snackbar(
          'Berhasil',
          'Akun berhasil dibuat! Mengalihkan...',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // D. Tunggu 1.5 detik saja (jangan kelamaan)
        await Future.delayed(const Duration(milliseconds: 1500));

        // E. PAKSA PINDAH KE HALAMAN LOGIN (Reset Route)
        // Ini akan menutup semua modal, dialog, sheet, dan balik ke Login
        Get.offAllNamed(AppRoutes.LOGIN_FORM);

        // Catatan: Kalau AppRoutes.LOGIN merah, coba ganti jadi Routes.LOGIN
        // (Sesuai isi file app_routes.dart temanmu)
      }
    } on AuthException catch (e) {
      Get.snackbar('Gagal Daftar', e.message, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
  // --- FUNGSI LUPA PASSWORD ---
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      Get.snackbar('Error', 'Harap isi email Anda dulu', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.posbankum.app://login-callback', // 👈 HARUS SAMA PERSIS dengan Tahap 1
      );

      Get.snackbar(
        'Cek Email',
        'Link reset password sudah dikirim ke email Anda. Cek Folder Spam juga ya!',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim email: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}