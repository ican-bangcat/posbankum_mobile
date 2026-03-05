import 'package:get/get.dart';

// ══════════════════════════════════════════════════════════════════════
// MODEL
// ══════════════════════════════════════════════════════════════════════

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
  final String judulKasus;
  final String idKasus;
  final String tanggalDibuat;
  final String status; // 'pending', 'diproses', 'selesai'
  final String kronologi;
  final List<TimelineItem> timeline;
  final String? catatanParalegal;
  final String? catatanTanggal;
  final String? catatanPenulis;

  DetailKasus({
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
}

// ══════════════════════════════════════════════════════════════════════
// CONTROLLER
// ══════════════════════════════════════════════════════════════════════

class DetailKasusController extends GetxController {
  final kasus = Rx<DetailKasus?>(null);
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() {
    isLoading.value = true;

    // ── Ganti variabel ini untuk preview 3 variasi ──
    // Opsi: 'pending', 'diproses', 'selesai'
    const String demoStatus = 'pending';

    switch (demoStatus) {
      case 'pending':
        kasus.value = _dummyPending();
        break;
      case 'diproses':
        kasus.value = _dummyDiproses();
        break;
      case 'selesai':
        kasus.value = _dummySelesai();
        break;
    }

    isLoading.value = false;
  }

  // ── DUMMY: Pending ──
  DetailKasus _dummyPending() {
    return DetailKasus(
      judulKasus: 'Sengketa Tanah Warisan',
      idKasus: '#PBH-2024-001234',
      tanggalDibuat: '12 Januari 2024',
      status: 'pending',
      kronologi:
      'Saya memiliki masalah terkait pembagian tanah warisan dari orang tua. '
          'Tanah tersebut seluas 500m2 yang seharusnya dibagi rata dengan 3 saudara kandung...',
      timeline: [
        TimelineItem(
          title: 'Pengaduan diterima',
          tanggal: '12 Jan 2024, 10:30',
          isActive: true,
        ),
        TimelineItem(
          title: 'Menunggu tindak lanjut',
          tanggal: null,
          isActive: false,
        ),
      ],
      catatanParalegal: null,
    );
  }

  // ── DUMMY: Diproses ──
  DetailKasus _dummyDiproses() {
    return DetailKasus(
      judulKasus: 'Sengketa Tanah Warisan',
      idKasus: '#PBH-2024-001234',
      tanggalDibuat: '12 Januari 2024',
      status: 'diproses',
      kronologi:
      'Saya memiliki masalah terkait pembagian tanah warisan dari orang tua. '
          'Tanah tersebut seluas 500m2 yang seharusnya dibagi rata dengan 3 saudara kandung...',
      timeline: [
        TimelineItem(
          title: 'Pengaduan diterima',
          tanggal: '12 Jan 2024, 10:30',
          isActive: true,
        ),
        TimelineItem(
          title: 'Ditinjau oleh paralegal',
          tanggal: '12 Jan 2024, 14:20',
          isActive: true,
        ),
        TimelineItem(
          title: 'Sedang dijadwalkan mediasi',
          tanggal: '13 Jan 2024, 09:15',
          isActive: true,
        ),
        TimelineItem(
          title: 'Menunggu tindak lanjut',
          tanggal: null,
          isActive: false,
        ),
      ],
      catatanParalegal:
      'Telah menghubungi pihak terkait untuk proses mediasi. '
          'Jadwal akan diinfokan segera.',
      catatanTanggal: '13 Jan 2024',
      catatanPenulis: 'Paralegal Ahmad',
    );
  }

  // ── DUMMY: Selesai ──
  DetailKasus _dummySelesai() {
    return DetailKasus(
      judulKasus: 'Sengketa Tanah Warisan',
      idKasus: '#PBH-2024-001234',
      tanggalDibuat: '12 Januari 2024',
      status: 'selesai',
      kronologi:
      'Saya memiliki masalah terkait pembagian tanah warisan dari orang tua. '
          'Tanah tersebut seluas 500m2 yang seharusnya dibagi rata dengan 3 saudara kandung...',
      timeline: [
        TimelineItem(
          title: 'Pengaduan diterima',
          tanggal: '12 Jan 2024, 10:30',
          isActive: true,
        ),
        TimelineItem(
          title: 'Ditinjau oleh paralegal',
          tanggal: '12 Jan 2024, 14:20',
          isActive: true,
        ),
        TimelineItem(
          title: 'Sedang dijadwalkan mediasi',
          tanggal: '13 Jan 2024, 09:15',
          isActive: true,
        ),
        TimelineItem(
          title: 'Mediasi Selesai',
          tanggal: '16 Jan 2024, 10:15',
          isActive: true,
        ),
        TimelineItem(
          title: 'Hasil Mediasi',
          tanggal: '17 Jan 2024, 18:15',
          isActive: true,
        ),
      ],
      catatanParalegal:
      'Telah menghubungi pihak terkait untuk proses mediasi. '
          'Jadwal akan diinfokan segera.',
      catatanTanggal: '13 Jan 2024',
      catatanPenulis: 'Paralegal Ahmad',
    );
  }

  // ── Aksi Ambil Kasus ──
  void ambilKasus() {
    Get.snackbar(
      'Berhasil',
      'Kasus berhasil diambil!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}