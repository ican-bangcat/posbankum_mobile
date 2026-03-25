import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// ── MODEL DATA (Disesuaikan dengan Schema Database) ──
class TimelineItem {
  final String title;
  final String? tanggal;
  final bool isActive;

  TimelineItem({
    required this.title,
    this.tanggal,
    this.isActive = true,
  });
}

class DetailKasus {
  final String id;
  final String judulKasus;
  final String idKasus;
  final String tanggalDibuat;
  final String status;
  final String kronologi;
  final List<TimelineItem> timeline;
  final String? catatanParalegal;
  final String? catatanTanggal;
  final String? catatanPenulis;

  DetailKasus({
    required this.id,
    required this.judulKasus,
    required this.idKasus,
    required this.tanggalDibuat,
    required this.status,
    required this.kronologi,
    required this.timeline,
    this.catatanParalegal,
    this.catatanTanggal,
    this.catatanPenulis,
  });

  factory DetailKasus.fromJson(Map<String, dynamic> json) {
    // Format Tanggal untuk Header
    String formattedDate = '-';
    if (json['tgl_lapor'] != null) {
      final dt = DateTime.parse(json['tgl_lapor']).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(dt);
    }

    // Format Tanggal untuk Timeline
    String timelineDate = '-';
    if (json['tgl_lapor'] != null) {
      final dt = DateTime.parse(json['tgl_lapor']).toLocal();
      timelineDate = DateFormat('dd MMM yyyy, HH:mm').format(dt);
    }

    // Logic Sederhana untuk Timeline berdasarkan Status
    String status = json['status'] ?? 'Pending';
    List<TimelineItem> generatedTimeline = [
      TimelineItem(
        title: 'Pengaduan diterima',
        tanggal: timelineDate,
        isActive: true,
      ),
    ];

    if (status.toLowerCase() == 'diproses') {
      generatedTimeline.add(TimelineItem(title: 'Ditinjau oleh paralegal', isActive: true));
    } else if (status.toLowerCase() == 'selesai') {
      generatedTimeline.add(TimelineItem(title: 'Ditinjau oleh paralegal', isActive: true));
      generatedTimeline.add(TimelineItem(title: 'Kasus Selesai', isActive: true));
    } else {
      generatedTimeline.add(TimelineItem(title: 'Menunggu tindak lanjut', isActive: false));
    }

    return DetailKasus(
      id: json['id'] ?? '',
      judulKasus: json['kategori_masalah'] ?? 'Tanpa Judul',
      idKasus: json['id'].toString().substring(0, 13).toUpperCase(),
      tanggalDibuat: formattedDate,
      status: status,
      // ✅ SESUAI TABEL: Kolomnya bernama 'kronologi'
      kronologi: json['kronologi'] ?? 'Tidak ada kronologi',
      timeline: generatedTimeline,
      catatanParalegal: null,
    );
  }
}

class DetailKasusController extends GetxController {
  final supabase = Supabase.instance.client;

  final kasus = Rx<DetailKasus?>(null);
  final isLoading = true.obs;

  final isParalegal = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkUserRole();
    fetchDetailKasus();
  }

  // ── 1. CEK ROLE USER (Sesuai 2 Tabel Database) ──
  Future<void> _checkUserRole() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      // Cek apakah ID user yang login ada di tabel 'paralegal'
      final response = await supabase
          .from('paralegal')
          .select('id')
          .eq('id', user.id)
          .maybeSingle(); // maybeSingle agar tidak error merah kalau tidak ketemu

      if (response != null) {
        // Jika ketemu di tabel paralegal, berarti dia paralegal
        isParalegal.value = true;
      } else {
        // Jika tidak ketemu, berarti dia masyarakat
        isParalegal.value = false;
      }
    }
  }

  // ── 2. TARIK DATA DETAIL KASUS ──
  Future<void> fetchDetailKasus() async {
    try {
      isLoading.value = true;

      final user = supabase.auth.currentUser;
      if (user == null) return;

      // SEMENTARA: Agar bisa ngetes UI langsung tanpa error lempar ID,
      // kita set ambil 1 data terakhir milik user ini.
      // (Nanti di-update kalau navigasi bawa ID sudah fix)
      final response = await supabase
          .from('pengaduan')
          .select()
          .order('tgl_lapor', ascending: false)
          .limit(1)
          .single();

      kasus.value = DetailKasus.fromJson(response);

    } catch (e) {
      print("Error Fetch Detail: $e");
      Get.snackbar("Info", "Data pengaduan belum tersedia");
    } finally {
      isLoading.value = false;
    }
  }

  // ── 3. LOGIC AMBIL KASUS (PARALEGAL SAJA) ──
  Future<void> ambilKasus() async {
    if (kasus.value == null) return;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final user = supabase.auth.currentUser;
      if (user == null) return;

      // ✅ SESUAI TABEL: Update status & paralegal_id
      await supabase.from('pengaduan').update({
        'status': 'Diproses',
        'paralegal_id': user.id,
      }).eq('id', kasus.value!.id);

      Get.back(); // Tutup Loading

      // Refresh Data UI
      await fetchDetailKasus();

      Get.snackbar(
        'Berhasil',
        'Kasus berhasil diambil. Silakan mulai penanganan.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.back(); // Tutup Loading
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}