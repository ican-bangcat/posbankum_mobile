import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeParalegalController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoadingData = true.obs;
  var countPending = 0.obs; // Untuk status 'menunggu'
  var countProses = 0.obs;  // Untuk status 'diproses'
  var countSelesai = 0.obs; // Untuk status 'selesai'
  var recentActivities = <Map<String, dynamic>>[].obs;
  var userName = 'Memuat...'.obs;
  var idPosbankumAktif = ''.obs;

  @override
  void onReady() {
    super.onReady();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoadingData.value = true;

      final user = supabase.auth.currentUser;
      if (user == null) throw 'Sesi tidak valid';

      // 1. 🚀 AMBIL DATA PROFIL ADMIN
      final profile = await supabase
          .from('profiles')
          .select('full_name, id_posbankum')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        userName.value = profile['full_name'] ?? 'Admin';
        String? idPosbankumAdmin = profile['id_posbankum'];

        if (idPosbankumAdmin != null) {
          idPosbankumAktif.value = idPosbankumAdmin;

          // 2. 🚀 HITUNG STATISTIK PENGADUAN BERDASARKAN ID POSBANKUM
          final responsePengaduan = await supabase
              .from('pengaduan')
              .select('id_pengaduan, status')
              .eq('id_posbankum', idPosbankumAdmin);

          int pending = 0, proses = 0, selesai = 0;
          List<String> listIdPengaduanPosbankum = []; // Untuk filter timeline nanti

          for (final item in responsePengaduan) {
            final status = (item['status']?.toString() ?? '').toLowerCase().trim();
            if (status == 'menunggu') pending++;
            else if (status == 'diproses') proses++;
            else if (status == 'selesai') selesai++;

            listIdPengaduanPosbankum.add(item['id_pengaduan'].toString());
          }

          countPending.value = pending;
          countProses.value = proses;
          countSelesai.value = selesai;

          // 3. 🚀 AMBIL AKTIVITAS TERBARU DARI TIMELINE (Hanya yang relevan dengan kasus Posbankum ini)
          if (listIdPengaduanPosbankum.isNotEmpty) {
            final responseTimeline = await supabase
                .from('pengaduan_timeline')
                .select('title, deskripsi, tanggal, created_by, pengaduan:id_pengaduan(judul_pengaduan)')
                .inFilter('id_pengaduan', listIdPengaduanPosbankum)
                .order('tanggal', ascending: false)
                .limit(5); // Ambil 5 aktivitas terbaru saja

            if (responseTimeline != null) {
              recentActivities.assignAll(List<Map<String, dynamic>>.from(responseTimeline));
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Kesalahan penarikan data dasbor: $e');
    } finally {
      isLoadingData.value = false;
    }
  }
}