import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/data/services/api_service.dart';

class MainDashboardController extends GetxController {
  final ApiService _apiService = ApiService();
  final _storage = GetStorage();

  // Bikin index default 2 (Home)
  var selectedIndex = 2.obs;

  // --- State Kelengkapan Profil ---
  var isNamaComplete = false.obs;
  var isNikComplete = false.obs;
  var isTeleponComplete = false.obs;
  var isAlamatComplete = false.obs;
  var isProfileChecking = false.obs;

  bool get isAllComplete =>
      isNamaComplete.value &&
      isNikComplete.value &&
      isTeleponComplete.value &&
      isAlamatComplete.value;

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  Future<void> checkProfileCompleteness() async {
    try {
      isProfileChecking.value = true;
      
      // Ambil data profile terbaru dari Laravel API
      final response = await _apiService.dio.get('/profile');

      if (response.data['status'] == true) {
        final userData = response.data['data'];
        
        // Cek Nama & Telepon (dari tabel users)
        isNamaComplete.value = (userData['nama_lengkap'] != null && userData['nama_lengkap'].toString().trim().isNotEmpty);
        isTeleponComplete.value = (userData['nomor_telepon'] != null && userData['nomor_telepon'].toString().trim().isNotEmpty);

        // Cek Data Masyarakat (NIK, Alamat, Wilayah)
        if (userData['role'] == 'warga' && userData['masyarakat'] != null) {
          final msk = userData['masyarakat'];
          isNikComplete.value = (msk['nik'] != null && msk['nik'].toString().trim().isNotEmpty);
          
          bool hasAlamat = (msk['alamat'] != null && msk['alamat'].toString().trim().isNotEmpty);
          bool hasRegion = (msk['id_kabupaten'] != null &&
              msk['id_kecamatan'] != null &&
              msk['id_kelurahan'] != null);
              
          isAlamatComplete.value = hasAlamat && hasRegion;
        } else {
          // Jika bukan warga (misal admin/paralegal), anggap data kependudukan beres
          isNikComplete.value = true;
          isAlamatComplete.value = true;
        }
        
        // Simpan update user ke storage lokal juga
        await _storage.write('user', userData);
      }
      
      debugPrint('📊 [CHECK PROFILE] Result: Nama=${isNamaComplete.value}, NIK=${isNikComplete.value}, Telp=${isTeleponComplete.value}, Alamat=${isAlamatComplete.value}');
      
    } catch (e) {
      debugPrint('❌ [CHECK PROFILE] Error: $e');
    } finally {
      isProfileChecking.value = false;
    }
  }
}
