import '../../../app/data/services/api_service.dart';

// ✅ Model khusus untuk Timeline
class ProgresItem {
  final String? idTimeline;
  final String title;
  final String deskripsi;
  final DateTime tanggal;
  final List<LampiranItem> lampiranList;

  ProgresItem({
    this.idTimeline,
    required this.title,
    required this.deskripsi,
    required this.tanggal,
    this.lampiranList = const [],
  });

  factory ProgresItem.fromJson(Map<String, dynamic> json, {List<LampiranItem> lampiranList = const []}) {
    final dateStr = json['created_at'] ?? json['tanggal'];
    return ProgresItem(
      idTimeline: json['id_timeline']?.toString(),
      title: json['title']?.toString() ?? 'Update Progres',
      deskripsi: json['deskripsi']?.toString() ?? '',
      tanggal: dateStr != null ? DateTime.parse(dateStr.toString()).toLocal() : DateTime.now(),
      lampiranList: lampiranList,
    );
  }
}

// ✅ Model Khusus Lampiran
class LampiranItem {
  final String? idTimeline;
  final String namaFile;
  final String _pathFile;
  final String? mimeType;

  LampiranItem({
    this.idTimeline,
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
    required this.id,
    required this.judul,
    required this.kategori,
    required this.deskripsi,
    required this.lokasi,
    required this.tanggalPengajuan,
    this.tanggalKejadian,
    this.waktuKejadian,
    required this.status,
    required this.prioritas,
    this.namaKlien,
    this.noHpKlien,
    this.nikPelapor,
    this.namaLurah,
    required this.lampiranList,
    this.catatanAdmin,
  });

  factory DetailKasusModel.fromJson(Map<String, dynamic> json, List<dynamic> lampiranData) {
    String rawKronologi = json['kronologi']?.toString() ?? 'Tidak ada kronologi';
    String parsedLurah = '-';
    String parsedDeskripsi = rawKronologi;

    if (rawKronologi.startsWith('Lurah/Kelurahan:') || rawKronologi.startsWith('Nama Lurah:')) {
      final parts = rawKronologi.split('\n\nKronologi:\n');
      if (parts.length > 1) {
        parsedLurah = parts[0]
            .replaceAll('Lurah/Kelurahan: ', '')
            .replaceAll('Nama Lurah: ', '')
            .trim();
        parsedDeskripsi = parts[1].trim();
      }
    }

    return DetailKasusModel(
      id: json['id_pengaduan']?.toString() ?? '',
      judul: json['judul_pengaduan']?.toString() ?? 'Tanpa Judul',
      kategori: json['jenis_masalah']?.toString() ?? 'Lain-lain',
      deskripsi: parsedDeskripsi,
      lokasi: json['lokasi_kejadian']?.toString() ?? 'Lokasi tidak diketahui',
      tanggalPengajuan: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : DateTime.now(),
      tanggalKejadian: json['tanggal_kejadian'] != null ? DateTime.parse(json['tanggal_kejadian']).toLocal() : null,
      waktuKejadian: json['waktu_kejadian']?.toString(),
      status: json['status']?.toString().toLowerCase() ?? 'menunggu',
      prioritas: json['prioritas']?.toString() ?? 'Normal',
      namaKlien: json['nama_pelapor']?.toString() ?? 'Masyarakat (Klien)',
      noHpKlien: json['nomor_telepon']?.toString() ?? '-',
      nikPelapor: json['nik']?.toString() ?? '-',
      namaLurah: parsedLurah,
      lampiranList: lampiranData.map((e) => LampiranItem(
        idTimeline: e['id_timeline']?.toString(),
        namaFile: e['nama_file']?.toString() ?? 'File Terlampir',
        pathFile: e['path_file']?.toString() ?? '',
        mimeType: e['mime_type']?.toString(),
      )).toList(),
      // DB column = 'catatan_internal', bukan 'catatan_admin'
      catatanAdmin: json['catatan_internal']?.toString(),
    );
  }
}
