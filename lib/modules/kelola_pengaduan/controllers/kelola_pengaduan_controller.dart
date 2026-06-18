import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../app/data/services/api_service.dart';

// Definisi model data kasus
class KasusItem {
  final String id;
  final String judul;
  final String kategori;
  final String deskripsi;
  final String lokasi;
  final DateTime tanggalPengajuan;
  final DateTime? tanggalKejadian;
  final String status;
  final String prioritas; // 🚀 TAMBAHAN BARU
  final String? namaKlien;
  final String? noHpKlien;

  KasusItem({
    required this.id, required this.judul, required this.kategori,
    required this.deskripsi, required this.lokasi, required this.tanggalPengajuan,
    this.tanggalKejadian, required this.status, required this.prioritas,
    this.namaKlien, this.noHpKlien,
  });

  factory KasusItem.fromJson(Map<String, dynamic> json) {
    return KasusItem(
      // 🚀 FIX: Sesuaikan dengan nama kolom database yang baru!
      id: json['id_pengaduan']?.toString() ?? '',
      judul: json['judul_pengaduan']?.toString() ?? 'Tanpa Judul',
      kategori: json['jenis_masalah']?.toString() ?? 'Lain-lain',
      deskripsi: json['kronologi']?.toString() ?? 'Tidak ada kronologi',
      lokasi: json['lokasi_kejadian']?.toString() ?? 'Lokasi tidak diketahui',
      tanggalPengajuan: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : DateTime.now(),
      tanggalKejadian: json['tanggal_kejadian'] != null ? DateTime.parse(json['tanggal_kejadian']).toLocal() : null,
      status: json['status']?.toString().toLowerCase() ?? 'menunggu',
      prioritas: json['prioritas']?.toString() ?? 'Normal',
      namaKlien: json['nama_pelapor']?.toString() ?? 'Masyarakat (Klien)', // Langsung baca dari tabel
      noHpKlien: json['nomor_telepon']?.toString() ?? '-', // Langsung baca dari tabel
    );
  }
}

class KelolaPengaduanController extends GetxController {
  final ApiService _apiService = ApiService();

  var selectedTab = 0.obs;
  var searchQuery = ''.obs;
  var isLoading = true.obs;
  var allKasus = <KasusItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPengaduan();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  Future<void> fetchPengaduan() async {
    try {
      isLoading.value = true;

      final response = await _apiService.dio.get('/pengaduan');

      if (response.data['status'] == true) {
        final List<dynamic> data = response.data['data'];
        final List<KasusItem> fetchedData = data
            .map((e) => e is Map<String, dynamic> ? KasusItem.fromJson(e) : KasusItem.fromJson(Map<String, dynamic>.from(e)))
            .where((kasus) => kasus.status != 'dibatalkan')
            .toList();
        allKasus.assignAll(fetchedData);
      } else {
        throw response.data['message'] ?? 'Gagal mengambil data pengaduan';
      }
    } catch (e) {
      debugPrint('Kegagalan sinkronisasi data pengaduan: $e');
      Get.snackbar('Error', 'Gagal memuat data pengaduan: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // 🚀 FIX: Konversi dari kolom 'prioritas' database ke angka untuk sorting (Level 1 paling Urgent)
  int getPriorityValue(String prioritas) {
    switch(prioritas) {
      case 'Sangat Tinggi': return 1;
      case 'Tinggi': return 2;
      case 'Menengah': return 3;
      case 'Normal': return 4;
      case 'Rendah': return 5;
      default: return 4;
    }
  }

  // Getter reaktif untuk filtrasi dan pencarian
  List<KasusItem> get filteredKasus {
    List<KasusItem> filtered = allKasus.where((kasus) {
      bool matchTab = true;
      if (selectedTab.value == 1) matchTab = (kasus.status == 'proses' || kasus.status == 'diproses');
      if (selectedTab.value == 2) matchTab = kasus.status == 'selesai';

      bool matchSearch = kasus.judul.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          kasus.kategori.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          kasus.lokasi.toLowerCase().contains(searchQuery.value.toLowerCase());

      return matchTab && matchSearch;
    }).toList();

    // 🚀 FIX: Mengurutkan hasil berdasarkan bobot prioritas tertinggi, lalu urgensi waktu (baru ke lama)
    filtered.sort((a, b) {
      int prioA = getPriorityValue(a.prioritas);
      int prioB = getPriorityValue(b.prioritas);

      if (prioA != prioB) {
        return prioA.compareTo(prioB); // Prioritas 1 ada di paling atas
      } else {
        return b.tanggalPengajuan.compareTo(a.tanggalPengajuan); // Kasus terbaru di atas
      }
    });

    return filtered;
  }
}