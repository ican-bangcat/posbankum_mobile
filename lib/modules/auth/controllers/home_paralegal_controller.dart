import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../main.dart'; // ✅ WAJIB IMPORT INI biar bisa panggil supabaseB

class HomeParalegalController extends GetxController {
  // Client DB A (untuk nembak Edge Function)
  final supabaseA = Supabase.instance.client;

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

// Di dalam HomeParalegalController lo
  Future<void> fetchDashboardData() async {
    try {
      isLoadingData.value = true;

      final sessionDB = supabaseB.auth.currentSession;
      final userMeta = supabaseB.auth.currentUser?.userMetadata;

      if (sessionDB == null || userMeta == null) throw 'Sesi tidak valid';

      String namaPosbankum = userMeta['nama'] ?? userMeta['nama_posbankum'] ?? '';
      userName.value = namaPosbankum;

      final posbankumId = userMeta['id_posbankum'];
      final token = sessionDB.accessToken;
      String keywordKelurahan = namaPosbankum.replaceAll('Posbankum', '').trim();

      // TEMBAK EDGE FUNCTION
      final response = await supabaseA.functions.invoke(
        'get-pengaduan-paralegal',
        body: {
          'posbankum_id': posbankumId,
          'kelurahan': keywordKelurahan, // 🚀 SINKRONKAN JUGA DI SINI
          'token': token
        },
      );

      if (response.data != null) {
        final List<dynamic> allPengaduan = response.data;
        int pending = 0, proses = 0, selesai = 0;

        for (final item in allPengaduan) {
          final status = (item['status']?.toString() ?? '').toLowerCase().trim();
          if (status == 'pending') pending++;
          else if (status == 'proses' || status == 'dalam proses' || status == 'diproses') proses++;
          else if (status == 'selesai') selesai++;
        }

        countPending.value = pending;
        countProses.value = proses;
        countSelesai.value = selesai;

        // ... Sisa logika sorting top 3 recent activities biarkan sama ...
      }
    } catch (e) {
      print('❌ Error dashboard fetch: $e');
    } finally {
      isLoadingData.value = false;
    }
  }
}