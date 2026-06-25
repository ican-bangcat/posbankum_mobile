// Definisi model data kasus
class KasusItem {
  final String id;
  final String judul;
  final String kategori;
  final String deskripsi;
  final String lokasi;
  final DateTime tanggalPengajuan;
  final DateTime? tanggalKejadian;
  final String status;
  final String prioritas; // 🚀 TAMBAHAN BARU
  final double priorityScore; // 🚀 SCORE DARI DATABASE
  final String? namaKlien;
  final String? noHpKlien;

  KasusItem({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.deskripsi,
    required this.lokasi,
    required this.tanggalPengajuan,
    this.tanggalKejadian,
    required this.status,
    required this.prioritas,
    required this.priorityScore,
    this.namaKlien,
    this.noHpKlien,
  });

  factory KasusItem.fromJson(Map<String, dynamic> json) {
    return KasusItem(
      // 🚀 FIX: Sesuaikan dengan nama kolom database yang baru!
      id: json['id_pengaduan']?.toString() ?? '',
      judul: json['judul_pengaduan']?.toString() ?? 'Tanpa Judul',
      kategori: json['jenis_masalah']?.toString() ?? 'Lain-lain',
      deskripsi: json['kronologi']?.toString() ?? 'Tidak ada kronologi',
      lokasi: json['lokasi_kejadian']?.toString() ?? 'Lokasi tidak diketahui',
      tanggalPengajuan: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : DateTime.now(),
      tanggalKejadian: json['tanggal_kejadian'] != null ? DateTime.parse(json['tanggal_kejadian']).toLocal() : null,
      status: json['status']?.toString().toLowerCase() ?? 'menunggu',
      prioritas: json['prioritas']?.toString() ?? 'Normal',
      priorityScore: json['priority_score'] != null ? double.parse(json['priority_score'].toString()) : 0.0,
      namaKlien: json['nama_pelapor']?.toString() ?? 'Masyarakat (Klien)', // Langsung baca dari tabel
      noHpKlien: json['nomor_telepon']?.toString() ?? '-', // Langsung baca dari tabel
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
  final KasusItem kasus;
  CardElement(this.kasus);
}
