import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../../../widgets/pdf_viewer_screen.dart';
import '../../../app/data/services/api_service.dart';

class TimelineItem {
  final String title;
  final String? tanggal;
  final String? description;
  final bool isActive;

  TimelineItem({required this.title, this.tanggal, this.description, this.isActive = true});
}

class LampiranItem {
  final String namaFile;
  final String pathFile;
  final String? mimeType;

  LampiranItem({required this.namaFile, required this.pathFile, this.mimeType});
}

class DetailKasus {
  final String id;
  final String judulLaporan;
  final String kategoriMasalah;
  final String idKasus;
  final String tanggalDibuat;
  final String? tanggalSelesai;
  final String status;
  final String kronologi;
  final List<TimelineItem> timeline;
  final List<LampiranItem> lampiranUrls;
  final String? catatanParalegal;
  // ✅ Data tambahan ditarik untuk detail Selesai
  final String lokasi;
  final String namaPelapor;

  DetailKasus({
    required this.id,
    required this.judulLaporan,
    required this.kategoriMasalah,
    required this.idKasus,
    required this.tanggalDibuat,
    this.tanggalSelesai,
    required this.status,
    required this.kronologi,
    required this.timeline,
    required this.lampiranUrls,
    this.catatanParalegal,
    required this.lokasi,
    required this.namaPelapor,
  });

  factory DetailKasus.fromJson(Map<String, dynamic> json, List<LampiranItem> lampiranUrlsDB, List<Map<String, dynamic>> timelineDB) {
    String formattedDate = '-';
    if (json['created_at'] != null) {
      final dt = DateTime.parse(json['created_at']).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(dt);
    }

    String? formattedSelesai;
    if (json['tgl_selesai'] != null) {
      final dtSelesai = DateTime.parse(json['tgl_selesai']).toLocal();
      formattedSelesai = DateFormat('dd MMM yyyy').format(dtSelesai);
    }

    String status = json['status']?.toString().toLowerCase() ?? 'menunggu';

    List<TimelineItem> generatedTimeline = [];

    // 1. Hardcode langkah pertama
    generatedTimeline.add(TimelineItem(
      title: 'Pengaduan diajukan',
      tanggal: formattedDate,
      description: 'Laporan Anda telah berhasil terkirim ke sistem.',
      isActive: true,
    ));

    // 2. Loop data dari tabel pengaduan_timeline
    for (var t in timelineDB) {
      String tgl = '-';
      // DB column = 'created_at', bukan 'tanggal'
      if (t['created_at'] != null) {
        final dt = DateTime.parse(t['created_at']).toLocal();
        tgl = DateFormat('dd MMM yyyy').format(dt);
      }
      generatedTimeline.add(TimelineItem(
        title: t['title'] ?? 'Update Progres',
        tanggal: tgl,
        description: t['deskripsi'],
        isActive: true,
      ));
    }

    // 3. Status ujung/akhir
    if (status == 'menunggu' || status == 'pending') {
      generatedTimeline.add(TimelineItem(
        title: 'Menunggu tindak lanjut',
        description: 'Tim paralegal akan segera memeriksa laporan Anda.',
        isActive: false,
      ));
    } else if (status == 'selesai') {
      generatedTimeline.add(TimelineItem(
        title: 'Kasus Selesai',
        tanggal: formattedSelesai,
        description: 'Seluruh rangkaian penanganan perkara telah selesai dilakukan.',
        isActive: true,
      ));
    } else if (status == 'dibatalkan') {
      generatedTimeline.add(TimelineItem(
        title: 'Pengaduan Dibatalkan',
        isActive: true,
        tanggal: '-',
        description: 'Pengaduan telah dibatalkan oleh pengguna.',
      ));
    }

    return DetailKasus(
      id: json['id_pengaduan'].toString(),
      judulLaporan: json['judul_pengaduan'] ?? 'Tanpa Judul',
      kategoriMasalah: json['jenis_masalah'] ?? 'Tanpa Kategori',
      idKasus: json['nomor_pengaduan']?.toString().toUpperCase() ?? 'TIDAK ADA TIKET',
      tanggalDibuat: formattedDate,
      tanggalSelesai: formattedSelesai,
      status: status,
      kronologi: json['kronologi'] ?? 'Tidak ada kronologi',
      timeline: generatedTimeline,
      lampiranUrls: lampiranUrlsDB,
      // DB column = 'catatan_internal', bukan 'catatan_admin'
      catatanParalegal: json['catatan_internal'],
      // ✅ AMBIL DATA LOKASI & NAMA DARI JSON
      lokasi: json['lokasi_kejadian']?.toString() ?? 'Lokasi tidak diketahui',
      namaPelapor: json['nama_pelapor']?.toString() ?? 'Nama Pelapor',
    );
  }
}

class DetailKasusController extends GetxController {
  final ApiService _apiService = ApiService();
  final kasus = Rx<DetailKasus?>(null);
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDetailKasus();
  }

  Future<void> fetchDetailKasus() async {
    try {
      isLoading.value = true;
      final rawId = Get.arguments;
      if (rawId == null) return;

      final pengaduanId = rawId.toString();

      final response = await _apiService.dio.get('/pengaduan/$pengaduanId');
      final lampiranResponse = await _apiService.dio.get('/pengaduan/$pengaduanId/lampiran');
      final timelineResponse = await _apiService.dio.get('/pengaduan/$pengaduanId/timeline');

      if (response.data['status'] == true) {
        final detailData = response.data['data'];

        List<LampiranItem> urls = [];
        if (lampiranResponse.data['status'] == true) {
          urls = (lampiranResponse.data['data'] as List)
              .map((e) => LampiranItem(
                    namaFile: e['nama_file'].toString(),
                    pathFile: e['path_file'].toString(),
                    mimeType: e['mime_type']?.toString(),
                  ))
              .toList();
        }

        List<Map<String, dynamic>> timelineData = [];
        if (timelineResponse.data['status'] == true) {
          timelineData = List<Map<String, dynamic>>.from(timelineResponse.data['data']);
        }

        kasus.value = DetailKasus.fromJson(detailData, urls, timelineData);
      }
    } catch (e) {
      print("❌ Error Fetch Detail: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 🚀 FUNGSI SAKTI BUKA LAMPIRAN (Langsung buka URL via API terproteksi)
  Future<void> bukaLampiran(String urlFromDb, String? mimeType, {String? namaFile}) async {
    try {
      final String lowerPath = urlFromDb.toLowerCase();
      bool isImage = false;
      if (mimeType != null) {
        isImage = mimeType.toLowerCase().contains('image');
      } else {
        isImage = lowerPath.contains('.jpg') || lowerPath.contains('.jpeg') || lowerPath.contains('.png') || lowerPath.contains('image');
      }

      final token = GetStorage().read('token');
      final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};

      if (isImage) {
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
                      urlFromDb,
                      headers: headers, // 👈 Kirim token auth
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
        // --- LOGIKA PDF: Unduh secara aman ke Cache, lalu Buka In-App ---
        Get.dialog(
          const Center(child: CircularProgressIndicator(color: Colors.white)),
          barrierDismissible: false,
        );

        final directory = await getTemporaryDirectory();
        final filename = namaFile ?? urlFromDb.split('/').last.split('?').first;
        final tempPath = "${directory.path}/$filename";

        // Dio download otomatis melampirkan token auth
        await _apiService.dio.download(
          urlFromDb,
          tempPath,
        );

        Get.back(); // Tutup loading

        Get.to(() => PdfViewerScreen(
          pdfPath: tempPath,
          title: filename,
        ));
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back(); // Tutup loading jika error terjadi
      Get.snackbar("Error", "Gagal membuka lampiran: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> batalkanPengaduan() async {
    if (kasus.value == null) return;
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      final response = await _apiService.dio.patch(
        '/pengaduan/${kasus.value!.id}/status',
        data: {
          'status': 'dibatalkan',
          'catatan_internal': 'Dibatalkan oleh Pelapor',
        },
      );

      Get.back();
      if (response.data['status'] == true) {
        fetchDetailKasus();
        Get.snackbar("Berhasil", "Pengaduan telah dibatalkan.", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        throw response.data['message'] ?? 'Gagal membatalkan pengaduan';
      }
    } catch (e) {
      Get.back();
      print("❌ Error Batal Pengaduan: $e");
      Get.snackbar("Gagal", "Gagal membatalkan pengaduan.", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}