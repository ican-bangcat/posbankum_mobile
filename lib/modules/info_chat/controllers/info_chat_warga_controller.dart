import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/data/services/api_service.dart';

class InfoChatWargaController extends GetxController {
  final ApiService _apiService;

  InfoChatWargaController({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  late String idPengaduan;

  // States
  var isMuted = false.obs;
  var isLoading = true.obs;

  // Data Klien (Warga/Pelapor)
  var namaKlien = 'Masyarakat (Klien)'.obs;
  var nik = '-'.obs;
  var noHp = '-'.obs;
  var namaLurah = '-'.obs;
  var alamatPelapor = '-'.obs;
  var fotoPelapor = ''.obs;

  // Data Kejadian & Kasus
  var judulKasus = 'Kasus Hukum'.obs;
  var nomorTiket = '-'.obs;
  var statusKasus = 'sedang diproses'.obs;
  var lokasiKejadian = '-'.obs;
  var tanggalKejadian = '-'.obs;
  var waktuKejadian = '-'.obs;

  // Berkas & Media
  var listLampiran = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    idPengaduan = Get.arguments?.toString() ?? '';
    if (idPengaduan.isNotEmpty) {
      loadInfoChatData();
    } else {
      isLoading.value = false;
    }
  }

  void toggleMute(bool value) {
    isMuted.value = value;
  }

  Future<void> loadInfoChatData() async {
    try {
      isLoading.value = true;

      // 1. Ambil detail pengaduan
      final response = await _apiService.dio.get('/pengaduan/$idPengaduan');

      if (response.data['status'] == true) {
        final data = response.data['data'];

        // Data Klien/Pelapor
        namaKlien.value = data['nama_pelapor'] ?? 'Masyarakat (Klien)';
        nik.value = data['nik'] ?? '-';
        noHp.value = data['nomor_telepon'] ?? '-';
        alamatPelapor.value = data['alamat_pelapor'] ?? '-';
        fotoPelapor.value = data['foto_profile_pelapor'] ?? '';

        // Data Kasus & Kejadian
        judulKasus.value = data['judul_pengaduan'] ?? data['jenis_masalah'] ?? 'Kasus Hukum';
        nomorTiket.value = data['nomor_pengaduan']?.toString().toUpperCase() ?? '-';
        statusKasus.value = (data['status'] ?? 'diproses').toString().toUpperCase();
        lokasiKejadian.value = data['lokasi_kejadian'] ?? '-';
        
        // Parsing Tanggal Kejadian
        if (data['tanggal_kejadian'] != null) {
          try {
            final dt = DateTime.parse(data['tanggal_kejadian'].toString());
            tanggalKejadian.value = "${dt.day} ${_getMonthName(dt.month)} ${dt.year}";
          } catch (_) {
            tanggalKejadian.value = data['tanggal_kejadian'].toString();
          }
        }
        waktuKejadian.value = data['waktu_kejadian']?.toString() ?? '-';

        // Parse nama lurah dari kronologi jika menggunakan format Lurah/Kelurahan
        String rawKronologi = data['kronologi']?.toString() ?? '';
        if (rawKronologi.startsWith('Lurah/Kelurahan:') || rawKronologi.startsWith('Nama Lurah:')) {
          final parts = rawKronologi.split('\n\nKronologi:\n');
          if (parts.length > 1) {
            namaLurah.value = parts[0]
                .replaceAll('Lurah/Kelurahan: ', '')
                .replaceAll('Nama Lurah: ', '')
                .trim();
          }
        }

        // 2. Ambil berkas lampiran
        final lampiranResponse = await _apiService.dio.get('/pengaduan/$idPengaduan/lampiran');
        if (lampiranResponse.data['status'] == true) {
          final List<dynamic> rawFiles = lampiranResponse.data['data'] ?? [];
          final mapped = rawFiles.map((e) {
            return {
              'nama_file': e['nama_file']?.toString() ?? 'File Lampiran',
              'path_file': e['path_file']?.toString() ?? '',
              'mime_type': e['mime_type']?.toString() ?? '',
              'jenis_lampiran': e['jenis_lampiran']?.toString() ?? 'bukti_awal',
            };
          }).toList();

          listLampiran.assignAll(mapped);
        }
      }
    } catch (e) {
      print("❌ Error load info chat warga data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String _getMonthName(int month) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
