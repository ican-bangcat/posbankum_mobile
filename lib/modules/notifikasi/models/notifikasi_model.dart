import 'package:intl/intl.dart';

class NotifikasiItem {
  final String idNotifikasi;
  final String? idPosbankum;
  final String? idUserPenerima;
  final String judul;
  final String pesan;
  final String kategori; // pengaduan, kegiatan, dokumen, sistem
  final String prioritas; // tinggi, sedang, rendah
  final bool isRead;
  final String? readAt;
  final String? refTable;
  final String? refId;
  final String createdAt;
  final String formattedTime;

  NotifikasiItem({
    required this.idNotifikasi,
    this.idPosbankum,
    this.idUserPenerima,
    required this.judul,
    required this.pesan,
    required this.kategori,
    required this.prioritas,
    required this.isRead,
    this.readAt,
    this.refTable,
    this.refId,
    required this.createdAt,
    required this.formattedTime,
  });

  factory NotifikasiItem.fromJson(Map<String, dynamic> json) {
    String rawDate = json['created_at']?.toString() ?? '';
    String timeStr = '-';

    if (rawDate.isNotEmpty) {
      try {
        String dateToParse = rawDate;
        // Jika format MySQL standard yyyy-MM-dd HH:mm:ss tanpa offset, ubah ke ISO8601 UTC
        if (!dateToParse.contains('Z') && !dateToParse.contains('+') && dateToParse.contains(' ')) {
          dateToParse = dateToParse.replaceAll(' ', 'T') + 'Z';
        } else if (!dateToParse.contains('Z') && !dateToParse.contains('+') && !dateToParse.contains('T')) {
          dateToParse = dateToParse + 'Z';
        } else if (!dateToParse.contains('Z') && !dateToParse.contains('+') && dateToParse.contains('T')) {
          dateToParse = dateToParse + 'Z';
        }
        final dt = DateTime.parse(dateToParse).toLocal();
        final diff = DateTime.now().difference(dt);

        if (diff.inMinutes < 60) {
          timeStr = '${diff.inMinutes}m yang lalu';
        } else if (diff.inHours < 24) {
          timeStr = '${diff.inHours}j yang lalu';
        } else if (diff.inDays < 7) {
          timeStr = '${diff.inDays} hari lalu';
        } else {
          timeStr = DateFormat('dd MMM yyyy').format(dt);
        }
      } catch (_) {}
    }

    // handle is_read (mysql sends integer/tinyint 0 or 1)
    bool parsedIsRead = false;
    if (json['is_read'] != null) {
      if (json['is_read'] is bool) {
        parsedIsRead = json['is_read'] as bool;
      } else if (json['is_read'] is int) {
        parsedIsRead = (json['is_read'] as int) == 1;
      } else if (json['is_read'] is String) {
        parsedIsRead = json['is_read'] == '1' || json['is_read']?.toString().toLowerCase() == 'true';
      }
    }

    return NotifikasiItem(
      idNotifikasi: json['id_notifikasi']?.toString() ?? json['id']?.toString() ?? '',
      idPosbankum: json['id_posbankum']?.toString(),
      idUserPenerima: json['id_user_penerima']?.toString(),
      judul: json['judul'] ?? json['title'] ?? '',
      pesan: json['pesan'] ?? json['message'] ?? '',
      kategori: json['kategori'] ?? json['type'] ?? 'sistem',
      prioritas: json['prioritas'] ?? json['priority'] ?? 'sedang',
      isRead: parsedIsRead,
      readAt: json['read_at']?.toString(),
      refTable: json['ref_table']?.toString(),
      refId: json['ref_id']?.toString(),
      createdAt: rawDate,
      formattedTime: timeStr,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_notifikasi': idNotifikasi,
      'id_posbankum': idPosbankum,
      'id_user_penerima': idUserPenerima,
      'judul': judul,
      'pesan': pesan,
      'kategori': kategori,
      'prioritas': prioritas,
      'is_read': isRead ? 1 : 0,
      'read_at': readAt,
      'ref_table': refTable,
      'ref_id': refId,
      'created_at': createdAt,
    };
  }
}
