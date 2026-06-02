import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'kelola_pengaduan_controller.dart'; // Untuk memicu fetch ulang di halaman sebelumnya

// ✅ Model khusus untuk Timeline sesuai tabel pengaduan_timeline
class ProgresItem {
  final String title;
  final String deskripsi;
  final DateTime tanggal;

  ProgresItem({required this.title, required this.deskripsi, required this.tanggal});

  factory ProgresItem.fromJson(Map<String, dynamic> json) {
    return ProgresItem(
      title: json['title']?.toString() ?? 'Update Progres',
      deskripsi: json['deskripsi']?.toString() ?? '',
      tanggal: json['tanggal'] != null ? DateTime.parse(json['tanggal']) : DateTime.now(),
    );
  }
}

// ✅ Model khusus untuk halaman Detail
class DetailKasusModel {
  final String id;
  final String judul;
  final String kategori;
  final String deskripsi;
  final String lokasi;
  final DateTime tanggalPengajuan;
  final DateTime? tanggalKejadian;
  final String? waktuKejadian;
  final String status;
  final String prioritas;
  final String? namaKlien;
  final String? noHpKlien;
  final String? nikPelapor;
  final String? namaLurah;
  final List<String> lampiranUrls;
  final String? catatanAdmin; // Tambahan untuk nampilin alasan tolak jika ada

  DetailKasusModel({
    required this.id, required this.judul, required this.kategori,
    required this.deskripsi, required this.lokasi, required this.tanggalPengajuan,
    this.tanggalKejadian, this.waktuKejadian, required this.status, required this.prioritas,
    this.namaKlien, this.noHpKlien, this.nikPelapor, this.namaLurah, required this.lampiranUrls,
    this.catatanAdmin,
  });

  factory DetailKasusModel.fromJson(Map<String, dynamic> json, List<String> lampiran) {
    String rawKronologi = json['kronologi']?.toString() ?? 'Tidak ada kronologi';
    String parsedLurah = '-';
    String parsedDeskripsi = rawKronologi;

    if (rawKronologi.startsWith('Lurah/Kelurahan:')) {
      final parts = rawKronologi.split('\n\nKronologi:\n');
      if (parts.length > 1) {
        parsedLurah = parts[0].replaceAll('Lurah/Kelurahan: ', '').trim();
        parsedDeskripsi = parts[1].trim();
      }
    }

    return DetailKasusModel(
      id: json['id_pengaduan']?.toString() ?? '',
      judul: json['judul_pengaduan']?.toString() ?? 'Tanpa Judul',
      kategori: json['jenis_masalah']?.toString() ?? 'Lain-lain',
      deskripsi: parsedDeskripsi,
      lokasi: json['lokasi_kejadian']?.toString() ?? 'Lokasi tidak diketahui',
      tanggalPengajuan: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      tanggalKejadian: json['tanggal_kejadian'] != null ? DateTime.parse(json['tanggal_kejadian']) : null,
      waktuKejadian: json['waktu_kejadian']?.toString(),
      status: json['status']?.toString().toLowerCase() ?? 'menunggu',
      prioritas: json['prioritas']?.toString() ?? 'Normal',
      namaKlien: json['nama_pelapor']?.toString() ?? 'Masyarakat (Klien)',
      noHpKlien: json['nomor_telepon']?.toString() ?? '-',
      nikPelapor: json['nik']?.toString() ?? '-',
      namaLurah: parsedLurah,
      lampiranUrls: lampiran,
      catatanAdmin: json['catatan_admin']?.toString(),
    );
  }
}

class DetailKasusParalegalController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = true.obs;
  var isUpdating = false.obs;
  DetailKasusModel? kasus;
  var errorMessage = ''.obs;

  var listProgres = <ProgresItem>[].obs;

  // Controller untuk input alasan penolakan
  final alasanTolakC = TextEditingController();

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

  @override
  void onClose() {
    alasanTolakC.dispose();
    super.onClose();
  }

  // 🚀 FUNGSI AMBIL KASUS (Error Foreign Key Dihapus)
  Future<void> ambilKasus(String id) async {
    try {
      isUpdating.value = true;
      final userId = supabase.auth.currentUser?.id;

      // Update status saja, id_paralegal kita abaikan sementara biar nggak error
      await supabase.from('pengaduan').update({
        'status': 'diproses'
      }).eq('id_pengaduan', id);

      // Riwayat dicatat aman di timeline menggunakan created_by
      await supabase.from('pengaduan_timeline').insert({
        'id_pengaduan': id,
        'title': 'Kasus Diambil',
        'deskripsi': 'Paralegal telah mengambil kasus ini dan sedang dalam tahap peninjauan awal.',
        'created_by': userId
      });

      Get.snackbar('Berhasil', 'Kasus berhasil diambil! Silakan mulai peninjauan.', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);

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

  // 🚀 FUNGSI TOLAK KASUS (Error Foreign Key Dihapus)
  Future<void> tolakKasus(String id) async {
    if (alasanTolakC.text.trim().isEmpty) {
      Get.snackbar('Peringatan', 'Alasan penolakan wajib diisi!', backgroundColor: Colors.orange.shade700, colorText: Colors.white);
      return;
    }

    try {
      isUpdating.value = true;
      final userId = supabase.auth.currentUser?.id;

      // Update status jadi dibatalkan dan isi catatan admin, id_paralegal diabaikan
      await supabase.from('pengaduan').update({
        'status': 'dibatalkan',
        'catatan_admin': alasanTolakC.text.trim()
      }).eq('id_pengaduan', id);

      // Otomatis bikin timeline penolakan menggunakan created_by
      await supabase.from('pengaduan_timeline').insert({
        'id_pengaduan': id,
        'title': 'Kasus Ditolak',
        'deskripsi': 'Penolakan Kasus: ${alasanTolakC.text.trim()}',
        'created_by': userId
      });

      Get.back(); // Tutup dialog penolakan
      Get.snackbar('Berhasil', 'Kasus berhasil ditolak dan dikembalikan ke pelapor.', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);

      await fetchDetailKasus(id);
      if (Get.isRegistered<KelolaPengaduanController>()) {
        Get.find<KelolaPengaduanController>().fetchPengaduan();
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan: $e', backgroundColor: const Color(0xFFEF4444), colorText: Colors.white);
    } finally {
      isUpdating.value = false;
      alasanTolakC.clear();
    }
  }

  Future<void> fetchDetailKasus(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await supabase.from('pengaduan').select().eq('id_pengaduan', id).maybeSingle();

      if (response != null) {
        final lampiranData = await supabase.from('pengaduan_lampiran').select('path_file').eq('id_pengaduan', id);
        List<String> listLampiran = (lampiranData as List).map((e) => e['path_file'].toString()).toList();

        kasus = DetailKasusModel.fromJson(response, listLampiran);

        final progresResponse = await supabase
            .from('pengaduan_timeline')
            .select()
            .eq('id_pengaduan', id)
            .order('tanggal', ascending: false);

        final List<ProgresItem> fetchedProgres = (progresResponse as List)
            .map((data) => ProgresItem.fromJson(data))
            .toList();

        listProgres.assignAll(fetchedProgres);
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
}