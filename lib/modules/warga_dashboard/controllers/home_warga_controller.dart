import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/data/services/api_service.dart';

class HomeWargaController extends GetxController {
  final ApiService _apiService = ApiService();
  final _storage = GetStorage();

  var isLoadingData = true.obs;
  var countAktif = 0.obs;
  var countSelesai = 0.obs;
  var recentHistory = <Map<String, dynamic>>[].obs;
  var userName = 'Memuat...'.obs;

  // Observable untuk mengecek kelengkapan profil
  var isProfileIncomplete = false.obs;

  @override
  void onReady() {
    super.onReady();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoadingData.value = true;

      // 1. Ambil Data Profil & Cek Kelengkapan
      final profileResponse = await _apiService.dio.get('/profile');
      if (profileResponse.data['status'] == true) {
        final userData = profileResponse.data['data'];
        userName.value = userData['nama_lengkap'] ?? 'User';

        // Logika Pengecekan Kelengkapan (Sama dengan MainDashboardController)
        bool incomplete = false;
        if (userData['nomor_telepon'] == null || userData['nomor_telepon'].toString().isEmpty) {
          incomplete = true;
        } else if (userData['masyarakat'] == null) {
          incomplete = true;
        } else {
          final msk = userData['masyarakat'];
          if (msk['nik'] == null || msk['alamat'] == null || msk['id_kelurahan'] == null) {
            incomplete = true;
          }
        }
        isProfileIncomplete.value = incomplete;
      }

      // 2. Ambil Statistik Pengaduan
      final statsResponse = await _apiService.dio.get('/pengaduan/statistik');
      if (statsResponse.data['status'] == true) {
        final stats = statsResponse.data['data'];
        // Backend return: { menunggu: X, diproses: Y, selesai: Z, dibatalkan: W }
        int aktif = (stats['menunggu'] ?? 0) + (stats['diproses'] ?? 0);
        countAktif.value = aktif;
        countSelesai.value = stats['selesai'] ?? 0;
      }

      // 3. Ambil Riwayat Terbaru (List Pengaduan)
      final pengaduanResponse = await _apiService.dio.get('/pengaduan');
      if (pengaduanResponse.data['status'] == true) {
        final List<dynamic> list = pengaduanResponse.data['data'];
        recentHistory.assignAll(list.take(3).map((e) => e as Map<String, dynamic>).toList());
      }

    } catch (e) {
      debugPrint('❌ Error dashboard masyarakat: $e');
    } finally {
      isLoadingData.value = false;
    }
  }
}
