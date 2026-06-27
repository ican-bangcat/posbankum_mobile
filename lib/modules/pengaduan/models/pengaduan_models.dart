import 'package:intl/intl.dart';
import '../../../app/data/services/api_service.dart';

class PengaduanItem {
  final String idDb;
  final String idTiket;
  final String judul;
  final String tanggal;
  final String kategoriMasalah;
  final String status;

  PengaduanItem({
    required this.idDb,
    required this.idTiket,
    required this.judul,
    required this.tanggal,
    required this.kategoriMasalah,
    required this.status,
  });

  factory PengaduanItem.fromJson(Map<String, dynamic> json) {
    String formattedDate = '-';
    if (json['created_at'] != null) {
      final dt = DateTime.parse(json['created_at']).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(dt);
    }
    return PengaduanItem(
      idDb: json['id_pengaduan'].toString(),
      idTiket: json['nomor_pengaduan']?.toString().toUpperCase() ?? 'TIDAK ADA TIKET',
      judul: json['judul_pengaduan'] ?? 'Tanpa Judul',
      tanggal: formattedDate,
      kategoriMasalah: json['jenis_masalah'] ?? 'Lain-lain',
      status: json['status'] ?? 'Pending',
    );
  }
}

class TimelineItem {
  final String title;
  final String? tanggal;
  final String? description;
  final bool isActive;

  TimelineItem({
    required this.title,
    this.tanggal,
    this.description,
    this.isActive = true,
  });
}

class LampiranItem {
  final String namaFile;
  final String _pathFile;
  final String? mimeType;

  LampiranItem({
    required this.namaFile,
    required String pathFile,
    this.mimeType,
  }) : _pathFile = pathFile;

  String get pathFile {
    if (_pathFile.startsWith('http://localhost') || 
        _pathFile.startsWith('https://localhost') || 
        _pathFile.startsWith('http://127.0.0.1') || 
        _pathFile.startsWith('https://127.0.0.1')) {
      final baseUri = Uri.parse(ApiService.baseUrl);
      final fileUri = Uri.parse(_pathFile);
      final newUri = fileUri.replace(
        scheme: baseUri.scheme,
        host: baseUri.host,
        port: baseUri.port,
      );
      return newUri.toString();
    }
    return _pathFile;
  }
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
  final String lokasi;
  final String namaPelapor;
  final String? nikPelapor;
  final String? noTelpPelapor;
  final String? tanggalKejadian;
  final String? waktuKejadian;
  final String? namaParalegal;

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
    this.nikPelapor,
    this.noTelpPelapor,
    this.tanggalKejadian,
    this.waktuKejadian,
    this.namaParalegal,
  });

  static String _toIndonesianDate(DateTime dt) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
  }

  factory DetailKasus.fromJson(
    Map<String, dynamic> json,
    List<LampiranItem> lampiranUrlsDB,
    List<Map<String, dynamic>> timelineDB,
  ) {
    String formattedDate = '-';
    if (json['created_at'] != null) {
      final dt = DateTime.parse(json['created_at']).toLocal();
      formattedDate = _toIndonesianDate(dt);
    }

    String? formattedSelesai;
    if (json['tgl_selesai'] != null) {
      final dtSelesai = DateTime.parse(json['tgl_selesai']).toLocal();
      formattedSelesai = _toIndonesianDate(dtSelesai);
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

    // Sort timelineDB ascending (oldest first, newest last) by created_at or tanggal
    final sortedTimeline = List<Map<String, dynamic>>.from(timelineDB);
    sortedTimeline.sort((a, b) {
      final aTimeStr = a['created_at'] ?? a['tanggal'];
      final bTimeStr = b['created_at'] ?? b['tanggal'];
      if (aTimeStr == null && bTimeStr == null) return 0;
      if (aTimeStr == null) return -1;
      if (bTimeStr == null) return 1;
      return DateTime.parse(aTimeStr.toString()).compareTo(DateTime.parse(bTimeStr.toString()));
    });

    // 2. Loop data dari tabel pengaduan_timeline
    for (var t in sortedTimeline) {
      String tgl = '-';
      final dateStr = t['created_at'] ?? t['tanggal'];
      if (dateStr != null) {
        final dt = DateTime.parse(dateStr.toString()).toLocal();
        tgl = _toIndonesianDate(dt);
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

    String? formattedKejadian;
    if (json['tanggal_kejadian'] != null) {
      try {
        final dtKejadian = DateTime.parse(json['tanggal_kejadian']);
        final months = [
          'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        String timePart = '';
        if (json['waktu_kejadian'] != null && json['waktu_kejadian'].toString().isNotEmpty) {
          final timeStr = json['waktu_kejadian'].toString();
          final tParts = timeStr.split(':');
          if (tParts.length >= 2) {
            timePart = ", ${tParts[0].padLeft(2, '0')}:${tParts[1].padLeft(2, '0')} WIB";
          } else {
            timePart = ", $timeStr WIB";
          }
        }
        formattedKejadian = "${dtKejadian.day} ${months[dtKejadian.month - 1]} ${dtKejadian.year}$timePart";
      } catch (e) {
        formattedKejadian = json['tanggal_kejadian']?.toString() ?? '-';
      }
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
      catatanParalegal: json['catatan_internal'],
      lokasi: json['lokasi_kejadian']?.toString() ?? 'Lokasi tidak diketahui',
      namaPelapor: json['nama_pelapor']?.toString() ?? 'Nama Pelapor',
      nikPelapor: json['nik']?.toString(),
      noTelpPelapor: json['nomor_telepon']?.toString(),
      tanggalKejadian: formattedKejadian,
      waktuKejadian: json['waktu_kejadian']?.toString(),
      namaParalegal: json['nama_paralegal']?.toString(),
    );
  }
}

abstract class ListElement {}

class HeaderElement extends ListElement {
  final String title;
  final int count;
  HeaderElement(this.title, this.count);
}

class CardElement extends ListElement {
  final PengaduanItem item;
  CardElement(this.item);
}
