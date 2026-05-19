import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Import untuk buka PDF/Gambar

// ── MODEL DATA ──
class TimelineItem {
  final String title;
  final String? tanggal;
  final bool isActive;

  TimelineItem({required this.title, this.tanggal, this.isActive = true});
}

class DetailKasus {
  final String id;
  final String judulLaporan; // ✅ Judul spesifik
  final String kategoriMasalah; // ✅ Kategori (Perdata, dll)
  final String idKasus;
  final String tanggalDibuat;
  final String status;
  final String kronologi;
  final List<TimelineItem> timeline;
  final List<String> lampiranUrls; // ✅ Array lampiran
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

  factory DetailKasus.fromJson(Map<String, dynamic> json) {
    String formattedDate = '-';
    if (json['tgl_lapor'] != null) {
      final dt = DateTime.parse(json['tgl_lapor']).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(dt);
    }

    String timelineDate = formattedDate;

    String status = json['status'] ?? 'Pending';
    List<TimelineItem> generatedTimeline = [
      TimelineItem(title: 'Pengaduan diterima', tanggal: timelineDate, isActive: true),
    ];

    if (status.toLowerCase() == 'diproses') {
      generatedTimeline.add(TimelineItem(title: 'Ditinjau oleh paralegal', isActive: true));
    } else if (status.toLowerCase() == 'selesai') {
      generatedTimeline.add(TimelineItem(title: 'Ditinjau oleh paralegal', isActive: true));
      generatedTimeline.add(TimelineItem(title: 'Kasus Selesai', isActive: true));
    } else if (status.toLowerCase() == 'dibatalkan') {
      generatedTimeline.add(TimelineItem(title: 'Pengaduan Dibatalkan', isActive: true, tanggal: '-'));
    } else {
      generatedTimeline.add(TimelineItem(title: 'Menunggu tindak lanjut', isActive: false));
    }

    return DetailKasus(
      id: json['id'].toString(),
      judulLaporan: json['judul_laporan'] ?? 'Tanpa Judul', // ✅ Map ke Judul Laporan
      kategoriMasalah: json['kategori_masalah'] ?? 'Tanpa Kategori', // ✅ Map ke Kategori
      idKasus: json['id'].toString().substring(0, 13).toUpperCase(),
      tanggalDibuat: formattedDate,
      status: status,
      kronologi: json['kronologi'] ?? 'Tidak ada kronologi',
      timeline: generatedTimeline,
      lampiranUrls: json['lampiran_urls'] != null ? List<String>.from(json['lampiran_urls']) : [], // ✅ Map Array URL
      catatanParalegal: json['catatan_paralegal'],
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

      final response = await supabase.from('pengaduan').select().eq('id', rawId.toString()).single();
      kasus.value = DetailKasus.fromJson(response);
    } catch (e) {
      print("Error Fetch Detail: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ FUNGSI BUKA LAMPIRAN KE BROWSER/PDF VIEWER HP
  Future<void> bukaLampiran(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar("Error", "Tidak dapat membuka file tersebut.");
      }
    } catch (e) {
      Get.snackbar("Error", "URL tidak valid.");
    }
  }

  // ✅ FUNGSI BATALKAN PENGADUAN
  Future<void> batalkanPengaduan() async {
    if (kasus.value == null) return;
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      await supabase.from('pengaduan').update({
        'status': 'Dibatalkan'
      }).eq('id', kasus.value!.id);

      Get.back(); // Tutup loading
      fetchDetailKasus(); // Refresh data
      Get.snackbar("Berhasil", "Pengaduan telah dibatalkan.", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.back();
      Get.snackbar("Gagal", "Gagal membatalkan pengaduan.", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}