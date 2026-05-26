import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/routes/app_routes.dart'; // Sesuaikan path routes-mu

class DaftarChatMasyarakatController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Tampungan data pengaduan yang sudah diterima (siap dichat)
  var acceptedComplaints = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDaftarChatBerjalan();
    listenToPengaduanChanges(); // Aktifkan real-time status pengaduan
  }

  // 1. Ambil data pengaduan yang statusnya 'Diterima'
  Future<void> fetchDaftarChatBerjalan() async {
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) return;

      // Ambil pengaduan milik sendiri yang statusnya sudah 'Diterima'
      final response = await _supabase
          .from('pengaduan')
          .select('id, judul_laporan, kategori_masalah, status, nama_paralegal_ditugaskan')
          .eq('masyarakat_id', userId)
          .eq('status', 'Diterima') // KUNCI UTAMA: Hanya yang diterima
          .order('tgl_lapor', ascending: false);

      acceptedComplaints.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat daftar chat: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Real-time Listener: Kalau tim web mengubah status pengaduan jadi 'Diterima',
  // otomatis langsung muncul di halaman chat mobile tanpa perlu restart app!
  void listenToPengaduanChanges() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _supabase
        .from('pengaduan')
        .stream(primaryKey: ['id'])
        .eq('masyarakat_id', userId)
        .listen((data) {
      // Filter manual dari stream untuk mengambil yang statusnya 'Diterima'
      final filtered = data.where((item) => item['status'] == 'Diterima').toList();
      acceptedComplaints.assignAll(filtered);
    });
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