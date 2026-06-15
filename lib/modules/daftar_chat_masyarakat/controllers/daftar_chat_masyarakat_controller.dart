import 'dart:async';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/data/services/api_service.dart';

class DaftarChatMasyarakatController extends GetxController {
  final ApiService _apiService = ApiService();
  Timer? _timer;

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

        // Map data agar sesuai dengan kunci yang dibaca oleh view
        final mapped = filtered.map((item) {
          return {
            'id': item['id_pengaduan']?.toString() ?? '',
            'judul_laporan': item['judul_pengaduan'] ?? item['jenis_masalah'] ?? 'Tanpa Judul',
            'kategori_masalah': item['jenis_masalah'] ?? 'Lain-lain',
            'nama_paralegal_ditugaskan': item['paralegal']?['nama_lengkap'] ?? item['nama_paralegal'] ?? 'Paralegal Posbankum',
            'status': item['status'] ?? 'diproses',
          };
        }).toList();

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