import 'dart:async';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/data/services/api_service.dart';

class DaftarChatMasyarakatController extends GetxController {
  final ApiService _apiService;
  Timer? _timer;

  DaftarChatMasyarakatController({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Tampungan data pengaduan yang sudah diterima (siap dichat)
  var acceptedComplaints = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDaftarChatBerjalan();
    // Jalankan timer refresh setiap 10 detik untuk menggantikan stream Supabase
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => fetchDaftarChatBerjalan());
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // 1. Ambil data pengaduan yang statusnya 'diproses' (diterima)
  Future<void> fetchDaftarChatBerjalan() async {
    try {
      if (acceptedComplaints.isEmpty) isLoading.value = true;

      // Ambil pengaduan milik sendiri dari Laravel REST API
      final response = await _apiService.dio.get('/pengaduan');

      if (response.data['status'] == true) {
        final List<dynamic> list = response.data['data'];
        
        // Filter pengaduan yang statusnya 'diproses'
        final filtered = list.where((item) {
          final status = (item['status'] ?? '').toString().toLowerCase();
          return status == 'diproses';
        }).toList();

        final List<Map<String, dynamic>> mapped = [];

        for (var item in filtered) {
          final idPengaduan = item['id_pengaduan']?.toString() ?? '';
          final rawMsg = item['last_message']?.toString() ?? '';

          String lastMsg = 'Klik untuk masuk ke ruang obrolan';
          if (rawMsg.isNotEmpty) {
            if (rawMsg.startsWith('[FILE]')) {
              lastMsg = '📎 Mengirim berkas';
            } else {
              lastMsg = rawMsg;
            }
          }

          String timeStr = '';
          DateTime? lastMsgTime;

          if (item['last_message_time'] != null) {
            try {
              String rawTime = item['last_message_time'].toString();
              if (!rawTime.endsWith('Z') && !rawTime.contains('+')) {
                rawTime += 'Z'; // Server menyimpan dalam UTC
              }
              final dt = DateTime.parse(rawTime).toLocal();
              lastMsgTime = dt;
              final now = DateTime.now();
              if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
                timeStr = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
              } else {
                timeStr = "${dt.day} ${_getMonthName(dt.month)}";
              }
            } catch (_) {}
          }

          final int unreadVal = int.tryParse(item['unread_count']?.toString() ?? '0') ?? 0;
          final fotoLawanBicara = item['foto_profile_lawan_bicara']?.toString() ?? '';

          mapped.add({
            'id': idPengaduan,
            'judul_laporan': item['judul_pengaduan'] ?? item['jenis_masalah'] ?? 'Tanpa Judul',
            'kategori_masalah': item['jenis_masalah'] ?? 'Lain-lain',
            'nama_paralegal_ditugaskan': item['paralegal']?['nama_lengkap'] ?? item['nama_paralegal'] ?? 'Paralegal Posbankum',
            'status': item['status'] ?? 'diproses',
            'last_message': lastMsg,
            'last_time': timeStr,
            'last_msg_time': lastMsgTime,
            'unread_count': unreadVal,
            'foto_lawan_bicara': fotoLawanBicara,
          });
        }

        // Sort: chat dengan pesan terbaru di atas
        mapped.sort((a, b) {
          final aTime = a['last_msg_time'] as DateTime?;
          final bTime = b['last_msg_time'] as DateTime?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime); // Descending
        });

        acceptedComplaints.assignAll(mapped);
      } else {
        throw response.data['message'] ?? 'Gagal memuat daftar chat';
      }
    } catch (e) {
      print("❌ Error fetch daftar chat: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  // Fungsi navigasi ke ruang chat dengan membawa ID Pengaduan
  void pindahKeDetailChat(String idPengaduan, String judulLaporan, String namaParalegal) {
    Get.toNamed(
      AppRoutes.DETAIL_CHAT_MASYARAKAT,
      arguments: {
        'id_pengaduan': idPengaduan,
        'judul_laporan': judulLaporan,
        'nama_paralegal': namaParalegal.isNotEmpty ? namaParalegal : 'Paralegal Posbankum',
      },
    );
  }
}