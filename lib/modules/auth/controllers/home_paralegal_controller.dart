import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeParalegalController extends GetxController {
  // Menggunakan instance tunggal Supabase (Single Source of Truth)
  final supabase = Supabase.instance.client;

  var isLoadingData = true.obs;
  var countPending = 0.obs;
  var countProses = 0.obs;
  var countSelesai = 0.obs;
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

      // Memverifikasi keberadaan sesi autentikasi pengguna yang sedang aktif
      final sessionDB = supabase.auth.currentSession;
      final userMeta = supabase.auth.currentUser?.userMetadata;

      if (sessionDB == null || userMeta == null) throw 'Sesi tidak valid';

      // Mengekstraksi identitas Posbankum dari metadata autentikasi
      String namaPosbankum = userMeta['nama'] ?? userMeta['nama_posbankum'] ?? '';
      userName.value = namaPosbankum;

      // Membersihkan string "Posbankum" untuk mendapatkan entitas Kelurahan spesifik
      String keywordKelurahan = namaPosbankum.replaceAll('Posbankum', '').trim();

      // MENGGANTI EDGE FUNCTION DENGAN QUERY NATIVE SUPABASE
      // TODO: Pastikan kolom 'nama_lurah' di tabel 'pengaduan' sudah sesuai dengan logika penugasan kasus
      final response = await supabase
          .from('pengaduan')
          .select()
          .ilike('nama_lurah', '%$keywordKelurahan%'); // Mengambil kasus yang mengandung nama kelurahan tersebut

      if (response != null) {
        final List<dynamic> allPengaduan = response;
        int pending = 0, proses = 0, selesai = 0;

        // Mengklasifikasikan pengaduan berdasarkan status penyelesaian
        for (final item in allPengaduan) {
          final status = (item['status']?.toString() ?? '').toLowerCase().trim();
          if (status == 'pending') pending++;
          else if (status == 'proses' || status == 'dalam proses' || status == 'diproses') proses++;
          else if (status == 'selesai') selesai++;
        }

        countPending.value = pending;
        countProses.value = proses;
        countSelesai.value = selesai;

        // Logika penyortiran aktivitas terbaru dapat ditambahkan kembali di sini jika diperlukan
      }
    } catch (e) {
      debugPrint('Kesalahan penarikan data dasbor: $e');
    } finally {
      isLoadingData.value = false;
    }
  }
}