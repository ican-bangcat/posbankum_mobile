import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ Jangan lupa import ini

class ProfileController extends GetxController {
  // Panggil client Supabase
  final supabase = Supabase.instance.client;

  // ── VARIABEL REAKTIF UNTUK UI ──
  var isLoading = true.obs;
  var namaLengkap = ''.obs;
  var displayId = ''.obs;
  var avatarUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Panggil fungsi ini otomatis saat halaman dibuka
    fetchUserData();
  }

  // ── FUNGSI AMBIL DATA PROFIL ──
  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;

      // Dapatkan data user yang sedang login saat ini
      final user = supabase.auth.currentUser;

      if (user != null) {
        // Tarik data dari tabel masyarakat berdasarkan ID user
        final data = await supabase
            .from('masyarakat')
            .select('nama, id, avatar_url')
            .eq('id', user.id)
            .maybeSingle(); // Ambil 1 baris data

        if (data != null) {
          // Masukkan ke variabel
          namaLengkap.value = data['nama'] ?? 'Pengguna Baru';

          // ID di Supabase bentuknya UUID panjang (misal: 123e4567-e89b-...).
          // Biar rapi kayak di desain (PB-2023-0045), kita ambil 8 huruf pertamanya aja untuk display.
          String rawId = data['id'].toString().substring(0, 8).toUpperCase();
          displayId.value = 'ID: PB-$rawId';

          avatarUrl.value = data['avatar_url'] ?? '';
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data profil: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }


  // ── FUNGSI LOGOUT (CUSTOM UI SESUAI FIGMA) ──
  void logout() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          // Radius 50px persis seperti inspect Figma kamu
          borderRadius: BorderRadius.circular(50),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Biar tinggi popup menyesuaikan isi
            children: [
              // --- GAMBAR TANDA TANYA ---
              Image.asset(
                'assets/images/icons/icon_ask_logout.png', // Nama file yang kita sepakati
                width: Get.width * 0.35, // Responsif: 35% dari lebar layar HP
                fit: BoxFit.contain,
                // Kasih icon cadangan kalau gambarnya belum kamu masukin
                errorBuilder: (c, e, s) => const Icon(
                  Icons.help_outline,
                  size: 80,
                  color: Color(0xFF2A2E5E),
                ),
              ),

              const SizedBox(height: 24),

              // --- TEKS KONFIRMASI ---
              const Text(
                'Apakah Anda ingin Keluar ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black, // Warna teks hitam pekat
                ),
              ),

              const SizedBox(height: 32),

              // --- BARISAN TOMBOL (Kiri Batal, Kanan Keluar) ---
              Row(
                children: [
                  // TOMBOL BATAL
                  Expanded( // Expanded bikin tombolnya responsif mentok kiri-kanan
                    child: ElevatedButton(
                      onPressed: () => Get.back(), // Tutup dialog
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2E5E), // Warna biru tua
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0, // Hilangkan bayangan bawaan
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12), // Jarak antar tombol

                  // TOMBOL KELUAR AKUN
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Tutup pop up-nya dulu biar UI terasa cepat
                        Get.back();

                        // Eksekusi logic Supabase
                        try {
                          await supabase.auth.signOut();
                          Get.offAllNamed('/login'); // Lempar ke halaman login
                        } catch (e) {
                          Get.snackbar('Error', 'Gagal logout: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2E5E), // Warna biru tua
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Keluar akun',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // User nggak bisa tutup popup dengan klik di luar kotak
    );
  }
}