import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/data/services/api_service.dart';

class HomeParalegalController extends GetxController {
  final ApiService _apiService = ApiService();
  final _storage = GetStorage();

  var isLoadingData = true.obs;
  var countPending = 0.obs; // Untuk status 'menunggu'
  var countProses = 0.obs;  // Untuk status 'diproses'
  var countSelesai = 0.obs; // Untuk status 'selesai'
  var recentActivities = <Map<String, dynamic>>[].obs;
  var userName = 'Memuat...'.obs;

  @override
  void onReady() {
    super.onReady();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoadingData.value = true;

      // 1. Ambil Data Profil
      final profileResponse = await _apiService.dio.get('/profile');
      if (profileResponse.data['status'] == true) {
        userName.value = profileResponse.data['data']['nama_lengkap'] ?? 'Paralegal';
      }

      // 2. Ambil Statistik Pengaduan (Otomatis difilter role di backend)
      final statsResponse = await _apiService.dio.get('/pengaduan/statistik');
      if (statsResponse.data['status'] == true) {
        final stats = statsResponse.data['data'];
        countPending.value = stats['menunggu'] ?? 0;
        countProses.value = stats['diproses'] ?? 0;
        countSelesai.value = stats['selesai'] ?? 0;
      }

      // 3. Ambil Aktivitas Terbaru (Mengambil list pengaduan terbaru sebagai aktivitas)
      final activityResponse = await _apiService.dio.get('/pengaduan');
      if (activityResponse.data['status'] == true) {
        final List<dynamic> list = activityResponse.data['data'];
        // Kita ambil 5 data terbaru untuk dashboard
        recentActivities.assignAll(list.take(5).map((e) => e as Map<String, dynamic>).toList());
      }

    } catch (e) {
      debugPrint('❌ Kesalahan penarikan data dasbor paralegal: $e');
    } finally {
      isLoadingData.value = false;
    }
  }
}
