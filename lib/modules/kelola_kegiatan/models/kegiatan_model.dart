import 'package:intl/intl.dart';

class KegiatanItem {
  final String id;
  final String judul;
  final String tanggal;
  final String lokasi;
  final String? imageUrl;
  final String status;
  final int jumlahAnggota;
  final String? deskripsi;
  final String? tglMulai;
  final String? tglSelesai;
  final int? jumlahPeserta;
  final List<String>? anggotaTerlibat;
  final String? catatan;

  KegiatanItem({
    required this.id,
    required this.judul,
    required this.tanggal,
    required this.lokasi,
    this.imageUrl,
    required this.status,
    required this.jumlahAnggota,
    this.deskripsi,
    this.tglMulai,
    this.tglSelesai,
    this.jumlahPeserta,
    this.anggotaTerlibat,
    this.catatan,
  });

  factory KegiatanItem.fromJson(Map<String, dynamic> json) {
    String formattedDate = '-';

    if (json['tgl_mulai'] != null) {
      final dt = DateTime.parse(json['tgl_mulai']).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(dt);
    }

    String? finalImageUrl = json['thumbnail_path'] ?? json['gambar'] ?? json['image'];
    if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
      if (finalImageUrl.startsWith('http://sibapak.pocari.id')) {
        finalImageUrl = finalImageUrl.replaceFirst('http://sibapak.pocari.id', 'https://sibapak.pocari.id');
      } else if (!finalImageUrl.startsWith('http')) {
        String cleanPath = finalImageUrl.startsWith('/') ? finalImageUrl.substring(1) : finalImageUrl;
        if (!cleanPath.startsWith('storage/')) {
          cleanPath = 'storage/$cleanPath';
        }
        finalImageUrl = 'https://sibapak.pocari.id/$cleanPath';
      }
    }

    int hitungAnggota = 0;
    List<String> anggotaList = [];
    if (json['anggota_terlibat'] != null) {
      if (json['anggota_terlibat'] is List) {
        anggotaList = (json['anggota_terlibat'] as List).map((e) => e.toString()).toList();
        hitungAnggota = anggotaList.length;
      } else if (json['anggota_terlibat'] is String) {
        // Fallback jika berupa JSON string ter-encode
        try {
          // parse jika string list
        } catch (_) {}
      }
    }

    return KegiatanItem(
      id: json['id_kegiatan']?.toString() ?? json['id']?.toString() ?? '',
      judul: json['judul'] ?? json['nama_kegiatan'] ?? '',
      tanggal: formattedDate,
      lokasi: json['lokasi'] ?? json['tempat'] ?? json['alamat'] ?? '',
      imageUrl: finalImageUrl,
      status: json['status'] ?? 'draft',
      jumlahAnggota: hitungAnggota,
      deskripsi: json['deskripsi'] ?? json['keterangan'] ?? json['catatan'] ?? '',
      tglMulai: json['tgl_mulai']?.toString(),
      tglSelesai: json['tgl_selesai']?.toString(),
      jumlahPeserta: json['jumlah_peserta'] != null
          ? int.tryParse(json['jumlah_peserta'].toString())
          : (json['target_peserta'] != null ? int.tryParse(json['target_peserta'].toString()) : null),
      anggotaTerlibat: anggotaList,
      catatan: json['catatan'] ?? json['catatan_internal'] ?? json['alasan_penolakan'] ?? json['keterangan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kegiatan': id,
      'judul': judul,
      'lokasi': lokasi,
      'thumbnail_path': imageUrl,
      'status': status,
      'deskripsi': deskripsi,
      'tgl_mulai': tglMulai,
      'tgl_selesai': tglSelesai,
      'jumlah_peserta': jumlahPeserta,
      'anggota_terlibat': anggotaTerlibat,
      'catatan': catatan,
    };
  }
}
