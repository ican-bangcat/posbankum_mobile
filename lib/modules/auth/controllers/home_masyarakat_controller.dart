import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeMasyarakatController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoadingData = true.obs;
  var countAktif = 0.obs;
  var countSelesai = 0.obs;
  var recentHistory = <Map<String, dynamic>>[].obs;
  var userName = 'Memuat...'.obs;

  @override
  void onReady() {
    super.onReady();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoadingData.value = true;

      // 1. Ambil ID user yang login
      final userId = supabase.auth.currentUser?.id;

      // ✅ Kunci utamanya di sini: Kalau belum login / null, langsung stop prosesnya.
      // Ini bikin Dart yakin kalau di kode bawahnya, userId PASTI ada isinya.
      if (userId == null) return;

      // 2. Ambil Nama User
      final userRes = await supabase.from('masyarakat').select('nama').eq('id', userId).maybeSingle();
      if (userRes != null && userRes['nama'] != null) {
        userName.value = userRes['nama'];
      }

      // 3. Ambil Data Pengaduan
      final List<dynamic> allPengaduan = await supabase
          .from('pengaduan')
          .select('id, status, kategori_masalah, tgl_lapor')
          .eq('masyarakat_id', userId) // ✅ Garis merah pasti hilang karena userId udah aman
          .order('tgl_lapor', ascending: false);

      int aktif = 0, selesai = 0;

      for (final item in allPengaduan) {
        final status = (item['status']?.toString() ?? '').toLowerCase().trim();

        // Kasus Aktif = Proses & Pending
        if (status == 'pending' || status == 'proses' || status == 'dalam proses' || status == 'diproses') {
          aktif++;
        } else if (status == 'selesai') {
          selesai++;
        }
      }

      countAktif.value = aktif;
      countSelesai.value = selesai;

      // Ambil 3 data teratas untuk Riwayat Terbaru
      recentHistory.assignAll(
          allPengaduan.take(3).map((e) => e as Map<String, dynamic>).toList()
      );

    } catch (e) {
      print('❌ Error dashboard masyarakat: $e');
    } finally {
      isLoadingData.value = false;
    }
  }
}