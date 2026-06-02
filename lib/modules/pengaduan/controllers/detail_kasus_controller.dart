import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TimelineItem {
  final String title;
  final String? tanggal;
  final bool isActive;

  TimelineItem({required this.title, this.tanggal, this.isActive = true});
}

class DetailKasus {
  final String id;
  final String judulLaporan;
  final String kategoriMasalah;
  final String idKasus;
  final String tanggalDibuat;
  final String status;
  final String kronologi;
  final List<TimelineItem> timeline;
  final List<String> lampiranUrls;
  final String? catatanParalegal;

  DetailKasus({
    required this.id,
    required this.judulLaporan,
    required this.kategoriMasalah,
    required this.idKasus,
    required this.tanggalDibuat,
    required this.status,
    required this.kronologi,
    required this.timeline,
    required this.lampiranUrls,
    this.catatanParalegal,
  });

  factory DetailKasus.fromJson(Map<String, dynamic> json, List<String> lampiranUrlsDB, List<Map<String, dynamic>> timelineDB) {
    String formattedDate = '-';
    if (json['created_at'] != null) {
      final dt = DateTime.parse(json['created_at']).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(dt);
    }

    String status = json['status']?.toString().toLowerCase() ?? 'menunggu';

    List<TimelineItem> generatedTimeline = [];

    // 1. Hardcode langkah pertama
    generatedTimeline.add(TimelineItem(title: 'Pengaduan diajukan', tanggal: formattedDate, isActive: true));

    // 2. Loop data dari tabel pengaduan_timeline
    for (var t in timelineDB) {
      String tgl = '-';
      if (t['tanggal'] != null) {
        final dt = DateTime.parse(t['tanggal']).toLocal();
        tgl = DateFormat('dd MMM yyyy').format(dt);
      }
      generatedTimeline.add(TimelineItem(title: t['title'] ?? 'Update Progres', tanggal: tgl, isActive: true));
    }

    // 3. Status ujung/akhir
    if (status == 'menunggu' || status == 'pending') {
      generatedTimeline.add(TimelineItem(title: 'Menunggu tindak lanjut', isActive: false));
    } else if (status == 'selesai') {
      generatedTimeline.add(TimelineItem(title: 'Kasus Selesai', isActive: true));
    } else if (status == 'dibatalkan') {
      generatedTimeline.add(TimelineItem(title: 'Pengaduan Dibatalkan', isActive: true, tanggal: '-'));
    }

    return DetailKasus(
      id: json['id_pengaduan'].toString(),
      judulLaporan: json['judul_pengaduan'] ?? 'Tanpa Judul',
      kategoriMasalah: json['jenis_masalah'] ?? 'Tanpa Kategori',
      idKasus: json['nomor_pengaduan']?.toString().toUpperCase() ?? 'TIDAK ADA TIKET',
      tanggalDibuat: formattedDate,
      status: status,
      kronologi: json['kronologi'] ?? 'Tidak ada kronologi',
      timeline: generatedTimeline,
      lampiranUrls: lampiranUrlsDB,
      catatanParalegal: json['catatan_admin'],
    );
  }
}

class DetailKasusController extends GetxController {
  final supabase = Supabase.instance.client;
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

      final response = await supabase.from('pengaduan').select().eq('id_pengaduan', pengaduanId).single();

      final lampiranResponse = await supabase.from('pengaduan_lampiran').select('path_file').eq('id_pengaduan', pengaduanId);
      List<String> urls = (lampiranResponse as List).map((e) => e['path_file'].toString()).toList();

      final timelineResponse = await supabase.from('pengaduan_timeline').select().eq('id_pengaduan', pengaduanId).order('tanggal', ascending: true);
      List<Map<String, dynamic>> timelineData = List<Map<String, dynamic>>.from(timelineResponse);

      kasus.value = DetailKasus.fromJson(response, urls, timelineData);
    } catch (e) {
      print("❌ Error Fetch Detail: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 🚀 FUNGSI SAKTI BUKA LAMPIRAN (Nembus Private Bucket)
  Future<void> bukaLampiran(String urlFromDb) async {
    try {
      // 1. Tampilkan loading agar UI tidak kaku saat nunggu balasan server
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      // 2. Ekstrak path asli file (Cari yang setelah nama bucket)
      String objectPath = urlFromDb;
      if (urlFromDb.contains('pengaduan-lampiran/')) {
        objectPath = urlFromDb.split('pengaduan-lampiran/').last;
        if (objectPath.contains('?')) objectPath = objectPath.split('?').first;
      }

      // 3. Request Signed URL ke Supabase (Valid 1 jam / 3600 detik)
      final String signedUrl = await supabase.storage
          .from('pengaduan-lampiran')
          .createSignedUrl(objectPath, 3600);

      // 4. Tutup Loading
      Get.back();

      // 5. Cek tipe file berdasar path (bukan dari signedUrl karena ada token)
      final String lowerPath = objectPath.toLowerCase();
      bool isImage = lowerPath.endsWith('.jpg') || lowerPath.endsWith('.jpeg') || lowerPath.endsWith('.png');

      if (isImage) {
        // --- LOGIKA GAMBAR: Pop-Up Dialog ---
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
                      signedUrl, // 👈 Pake link yang udah ditempel tiket masuk
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
        // --- LOGIKA PDF: Buka via Browser Bawaan HP ---
        final Uri uri = Uri.parse(signedUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar("Error", "Tidak dapat membuka file dokumen ini.", backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back(); // Jaga-jaga tutup loading jika error
      Get.snackbar("Akses Ditolak", "Gagal membuka lampiran: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> batalkanPengaduan() async {
    if (kasus.value == null) return;
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      await supabase.from('pengaduan').update({
        'status': 'dibatalkan'
      }).eq('id_pengaduan', kasus.value!.id);

      Get.back();
      fetchDetailKasus();
      Get.snackbar("Berhasil", "Pengaduan telah dibatalkan.", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.back();
      print("❌ Error Batal Pengaduan: $e");
      Get.snackbar("Gagal", "Gagal membatalkan pengaduan.", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}