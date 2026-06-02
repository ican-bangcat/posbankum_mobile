import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/routes/app_routes.dart';

class ProfilPosbankumController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = true.obs;

  var namaPosbankum = ''.obs;
  var email = ''.obs;
  var kabupaten = ''.obs;
  var kecamatan = ''.obs;
  var kelurahan = ''.obs;
  var alamat = ''.obs;
  var kodePos = ''.obs;
  var jmlParalegal = 0.obs;

  var paralegalList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfilDariWeb();
  }

  Future<void> fetchProfilDariWeb() async {
    try {
      isLoading.value = true;

      // 1. Cek Sesi User
      final user = supabase.auth.currentUser;
      if (user == null) {
        Get.snackbar('Sesi Berakhir', 'Silakan login kembali');
        return;
      }

      // 2. Ambil id_posbankum
      final profileData = await supabase
          .from('profiles')
          .select('id_posbankum')
          .eq('id', user.id)
          .maybeSingle();

      final idPosbankumAsli = profileData?['id_posbankum'];
      if (idPosbankumAsli == null) {
        Get.snackbar('Akses Ditolak', 'Akun Anda belum ditautkan ke Posbankum manapun.');
        return;
      }

      // 3. Tarik Data Utama Posbankum + Wilayah (Sihir JOIN)
      final dataPosbankum = await supabase
          .from('posbankum')
          .select('''
            nama, 
            email_akun, 
            alamat, 
            kode_pos, 
            kabupaten:id_kabupaten (nama), 
            kecamatan:id_kecamatan (nama), 
            kelurahan:id_kelurahan (nama)
          ''')
          .eq('id_posbankum', idPosbankumAsli)
          .maybeSingle();

      if (dataPosbankum != null) {
        // 4. Tarik Data Paralegal
        final dataParalegal = await supabase
            .from('paralegal_members')
            .select('nama_paralegal, nomor_telepon, is_primary')
            .eq('id_posbankum', idPosbankumAsli)
            .order('is_primary', ascending: false);

        // 5. Masukkan Data ke UI
        namaPosbankum.value = dataPosbankum['nama'] ?? '-';
        email.value = dataPosbankum['email_akun'] ?? '-';
        alamat.value = dataPosbankum['alamat'] ?? '-';
        kodePos.value = dataPosbankum['kode_pos'] ?? '-';

        // Ekstrak data Join wilayah
        kabupaten.value = dataPosbankum['kabupaten']?['nama'] ?? '-';
        kecamatan.value = dataPosbankum['kecamatan']?['nama'] ?? '-';
        kelurahan.value = dataPosbankum['kelurahan']?['nama'] ?? '-';

        if (dataParalegal.isNotEmpty) {
          paralegalList.assignAll(List<Map<String, dynamic>>.from(dataParalegal));
          jmlParalegal.value = paralegalList.length;
        } else {
          jmlParalegal.value = 0;
        }
      }

    } catch (e) {
      debugPrint('❌ Error fetchProfilDariWeb: $e');
      Get.snackbar('Error Sistem', 'Gagal menarik data profil Posbankum');
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI LOGOUT AMAN ---
  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Keluar Akun'),
        content: const Text('Yakin ingin keluar dari akun Posbankum ini?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Get.back();
              Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
              try {
                await supabase.auth.signOut();
                Get.offAllNamed(AppRoutes.LOGIN_FORM);
              } catch (e) {
                Get.back();
                Get.snackbar('Error', 'Gagal logout: $e');
              }
            },
            child: const Text('Ya, Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}