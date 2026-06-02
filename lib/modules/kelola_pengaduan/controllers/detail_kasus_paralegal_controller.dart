import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ IMPORT URL LAUNCHER
import 'kelola_pengaduan_controller.dart';

// ✅ Model khusus untuk Timeline
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

// ✅ Model Khusus Lampiran
class LampiranItem {
  final String namaFile;
  final String pathFile;
  final String? mimeType;

  LampiranItem({required this.namaFile, required this.pathFile, this.mimeType});
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
  final List<LampiranItem> lampiranList;
  final String? catatanAdmin;

  DetailKasusModel({
    required this.id, required this.judul, required this.kategori,
    required this.deskripsi, required this.lokasi, required this.tanggalPengajuan,
    this.tanggalKejadian, this.waktuKejadian, required this.status, required this.prioritas,
    this.namaKlien, this.noHpKlien, this.nikPelapor, this.namaLurah, required this.lampiranList,
    this.catatanAdmin,
  });

  factory DetailKasusModel.fromJson(Map<String, dynamic> json, List<dynamic> lampiranData) {
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
      lampiranList: lampiranData.map((e) => LampiranItem(
        namaFile: e['nama_file']?.toString() ?? 'File Terlampir',
        pathFile: e['path_file']?.toString() ?? '',
        mimeType: e['mime_type']?.toString(),
      )).toList(),
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

  Future<void> fetchDetailKasus(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await supabase.from('pengaduan').select().eq('id_pengaduan', id).maybeSingle();

      if (response != null) {
        final lampiranData = await supabase
            .from('pengaduan_lampiran')
            .select('nama_file, path_file, mime_type')
            .eq('id_pengaduan', id);

        kasus = DetailKasusModel.fromJson(response, lampiranData as List<dynamic>);

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

  Future<void> ambilKasus(String id) async {
    try {
      isUpdating.value = true;
      final userId = supabase.auth.currentUser?.id;

      await supabase.from('pengaduan').update({
        'status': 'diproses'
      }).eq('id_pengaduan', id);

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

  Future<void> tolakKasus(String id) async {
    if (alasanTolakC.text.trim().isEmpty) {
      Get.snackbar('Peringatan', 'Alasan penolakan wajib diisi!', backgroundColor: Colors.orange.shade700, colorText: Colors.white);
      return;
    }

    try {
      isUpdating.value = true;
      final userId = supabase.auth.currentUser?.id;

      await supabase.from('pengaduan').update({
        'status': 'dibatalkan',
        'catatan_admin': alasanTolakC.text.trim()
      }).eq('id_pengaduan', id);

      await supabase.from('pengaduan_timeline').insert({
        'id_pengaduan': id,
        'title': 'Kasus Ditolak',
        'deskripsi': 'Penolakan Kasus: ${alasanTolakC.text.trim()}',
        'created_by': userId
      });

      Get.back(); // Tutup dialog
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

  // 🚀 FUNGSI SAKTI BUKA LAMPIRAN (Sudah Support Private Bucket & Signed URL) 🚀
  Future<void> bukaLampiran(String pathFile, String? mimeType) async {
    try {
      // 1. Munculkan loading
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      // 2. Ekstrak path asli dari database
      String objectPath = pathFile;
      if (pathFile.contains('pengaduan-lampiran/')) {
        objectPath = pathFile.split('pengaduan-lampiran/').last;
        if (objectPath.contains('?')) objectPath = objectPath.split('?').first;
      }

      // 3. Minta URL Sementara ke Supabase (Berlaku 1 jam)
      final String signedUrl = await supabase.storage
          .from('pengaduan-lampiran')
          .createSignedUrl(objectPath, 3600);

      // Tutup loading
      Get.back();

      // Cek apakah file berupa gambar
      bool isImage = false;
      if (mimeType != null) {
        isImage = mimeType.toLowerCase().contains('image');
      } else {
        final String lowerPath = objectPath.toLowerCase();
        isImage = lowerPath.endsWith('.jpg') || lowerPath.endsWith('.jpeg') || lowerPath.endsWith('.png');
      }

      if (isImage) {
        // --- LOGIKA GAMBAR: Buka Pop-Up Dialog ---
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      signedUrl, // 👈 Pakai link sementaranya
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: const Text('Gagal memuat gambar', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0, right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.white, size: 36),
                    onPressed: () => Get.back(),
                  ),
                )
              ],
            ),
          ),
        );
      } else {
        // --- LOGIKA PDF/DOKUMEN LAIN: Buka ke Browser ---
        final Uri url = Uri.parse(signedUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar('Error', 'Tidak dapat membuka file dokumen ini.', backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back(); // Tutup loading kalau error
      Get.snackbar('Error', 'Terjadi kesalahan saat membuka lampiran: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}