import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeParalegalController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoadingData = true.obs;
  var countPending = 0.obs;
  var countProses = 0.obs;
  var countSelesai = 0.obs;
  var recentActivities = <Map<String, dynamic>>[].obs;
  var userName = 'Memuat...'.obs;
  @override
  void onReady() {
    super.onReady();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoadingData.value = true;
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        // Ambil nama dari tabel paralegal (sesuai schema, kolomnya nama_posbankum)
        final userRes = await supabase.from('paralegal').select('nama_posbankum').eq('id', userId).maybeSingle();
        if (userRes != null && userRes['nama_posbankum'] != null) {
          userName.value = userRes['nama_posbankum'];
        }
      }
      // 1. Hitung stats dari tabel pengaduan
      final List<dynamic> allPengaduan = await supabase
          .from('pengaduan')
          .select('status');

      int pending = 0, proses = 0, selesai = 0;

      for (final item in allPengaduan) {
        final status = (item['status']?.toString() ?? '').toLowerCase().trim();
        if (status == 'pending') {
          pending++;
        } else if (status == 'proses' ||
            status == 'dalam proses' ||
            status == 'diproses') {
          proses++;
        } else if (status == 'selesai') {
          selesai++;
        }
      }

      // 2. Ambil aktivitas terbaru
      // progres_kasus -> pengaduan -> paralegal (nested join)
      final List<dynamic> resRecent = await supabase
          .from('progres_kasus')
          .select('''
            *,
            pengaduan(
              kategori_masalah,
              paralegal(nama_posbankum)
            )
          ''')
          .order('created_at', ascending: false)
          .limit(3);

      // Update state
      countPending.value = pending;
      countProses.value = proses;
      countSelesai.value = selesai;
      recentActivities
          .assignAll(List<Map<String, dynamic>>.from(resRecent));
    } catch (e) {
      print('❌ Error dashboard fetch: $e');
    } finally {
      isLoadingData.value = false;
    }
  }
}