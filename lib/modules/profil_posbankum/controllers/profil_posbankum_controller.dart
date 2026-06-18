import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/data/services/api_service.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfilPosbankumController extends GetxController {
  final ApiService _apiService = ApiService();
  final _storage = GetStorage();

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

      // 1. Ambil id_posbankum dari profile user yang sedang login
      final profileResponse = await _apiService.dio.get('/profile');
      if (profileResponse.data['status'] != true) {
        Get.snackbar('Error', 'Gagal memuat data profile.');
        return;
      }

      final userData = profileResponse.data['data'];
      final idPosbankumAsli = userData['id_posbankum'];

      if (idPosbankumAsli == null) {
        Get.snackbar('Akses Ditolak', 'Akun Anda belum ditautkan ke Posbankum manapun.');
        return;
      }

      // 2. Tarik Data Utama Posbankum dari Laravel API
      final posbankumResponse = await _apiService.dio.get('/posbankum/$idPosbankumAsli');

      if (posbankumResponse.data['status'] == true) {
        final posbankumData = posbankumResponse.data['data'];
        
        namaPosbankum.value = posbankumData['nama'] ?? '-';
        email.value = posbankumData['email_akun'] ?? '-';
        alamat.value = posbankumData['alamat'] ?? '-';
        kodePos.value = posbankumData['kode_pos'] ?? '-';

        // Hubungan Wilayah dari Laravel
        kabupaten.value = posbankumData['kabupaten']?['nama'] ?? '-';
        kecamatan.value = posbankumData['kecamatan']?['nama'] ?? '-';
        kelurahan.value = posbankumData['kelurahan']?['nama'] ?? '-';

        // Hubungan Paralegal (biasanya dikembalikan di nested 'paralegals' atau 'paralegal_members')
        final List<dynamic> listParalegalRaw = posbankumData['paralegals'] ?? posbankumData['members'] ?? [];
        
        List<Map<String, dynamic>> mappedParalegals = listParalegalRaw.map((p) {
          final isPrimaryVal = p['is_primary'] ?? p['pivot']?['is_primary'] ?? 0;
          return {
            'nama_paralegal': p['nama_lengkap'] ?? p['nama_paralegal'] ?? p['name'] ?? '-',
            'nomor_telepon': p['nomor_telepon'] ?? p['no_hp'] ?? '-',
            'is_primary': isPrimaryVal == 1 || isPrimaryVal == true,
          };
        }).toList();

        // Urutkan is_primary = true paling atas
        mappedParalegals.sort((a, b) {
          final aPri = a['is_primary'] == true ? 1 : 0;
          final bPri = b['is_primary'] == true ? 1 : 0;
          return bPri.compareTo(aPri);
        });

        paralegalList.assignAll(mappedParalegals);
        jmlParalegal.value = paralegalList.length;
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
              if (Get.isRegistered<AuthController>()) {
                await Get.find<AuthController>().logout();
              } else {
                Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                try {
                  await _apiService.dio.post('/logout');
                  await _storage.remove('token');
                  await _storage.remove('user');
                  await _storage.remove('role');
                  await _storage.write('is_logged_in', false);
                  Get.offAllNamed(AppRoutes.LOGIN);
                } catch (e) {
                  await _storage.erase();
                  Get.offAllNamed(AppRoutes.LOGIN);
                }
              }
            },
            child: const Text('Ya, Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}