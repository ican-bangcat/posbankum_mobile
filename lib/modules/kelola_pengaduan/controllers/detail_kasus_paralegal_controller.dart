import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'kelola_pengaduan_controller.dart';

// ✅ Model untuk nyimpen riwayat progres
class ProgresItem {
  final String deskripsi;
  final DateTime tanggal;

  ProgresItem({required this.deskripsi, required this.tanggal});

  factory ProgresItem.fromJson(Map<String, dynamic> json) {
    return ProgresItem(
      deskripsi: json['deskripsi_progres']?.toString() ?? '',
      tanggal: json['tanggal_progres'] != null ? DateTime.parse(json['tanggal_progres']) : DateTime.now(),
    );
  }
}

class DetailKasusParalegalController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = true.obs;
  var isUpdating = false.obs;
  KasusItem? kasus;
  var errorMessage = ''.obs;

  // ✅ List untuk nyimpen riwayat progres
  var listProgres = <ProgresItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['id'] != null) {
      fetchDetailKasus(args['id'].toString());
    } else {
      isLoading.value = false;
      errorMessage.value = "ID Kasus hilang karena halaman di-refresh. Silakan kembali.";
    }
  }

  Future<void> ambilKasus(String id) async {
    try {
      isUpdating.value = true;
      await supabase.from('pengaduan').update({'status': 'proses'}).eq('id', id);
      Get.snackbar('Berhasil', 'Kasus berhasil diambil!', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
      await fetchDetailKasus(id);
      if (Get.isRegistered<KelolaPengaduanController>()) {
        Get.find<KelolaPengaduanController>().fetchPengaduan();
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan: $e', backgroundColor: const Color(0xFFEF4444), colorText: Colors.white);
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> fetchDetailKasus(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 1. Ambil data pengaduan (tetap pakai manual join agar aman dari error cache Supabase)
      final Map<String, dynamic>? response = await supabase.from('pengaduan').select().eq('id', id).maybeSingle();

      if (response != null) {
        String namaMasyarakat = 'Masyarakat (Klien)';
        String noHpMasyarakat = '-';

        if (response['masyarakat_id'] != null) {
          try {
            final userResponse = await supabase.from('masyarakat').select('nama, no_hp').eq('id', response['masyarakat_id']).maybeSingle();
            if (userResponse != null) {
              namaMasyarakat = userResponse['nama']?.toString() ?? namaMasyarakat;
              noHpMasyarakat = userResponse['no_hp']?.toString() ?? noHpMasyarakat;
            }
          } catch (e) { print('Gagal ambil klien'); }
        }

        response['masyarakat'] = {'nama': namaMasyarakat, 'no_hp': noHpMasyarakat};
        kasus = KasusItem.fromJson(response);

        // ✅ 2. AMBIL DATA RIWAYAT PROGRES DARI TABEL BARU
        final progresResponse = await supabase
            .from('progres_kasus')
            .select()
            .eq('pengaduan_id', id)
            .order('tanggal_progres', ascending: false); // Yg paling baru di atas

        final List<ProgresItem> fetchedProgres = (progresResponse as List)
            .map((data) => ProgresItem.fromJson(data))
            .toList();

        listProgres.assignAll(fetchedProgres); // Masukkan ke list UI

      } else {
        errorMessage.value = "Data kasus tidak ditemukan di database";
      }
    } catch (e) {
      print('Error detail: $e');
      errorMessage.value = "Gagal memuat data: $e";
    } finally {
      isLoading.value = false;
    }
  }

  bool isUrgent(String kategori) {
    return (kategori.toLowerCase().contains('fisik') || kategori.toLowerCase().contains('seksual') || kategori.toLowerCase().contains('narkotika'));
  }
}