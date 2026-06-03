import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeMasyarakatController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoadingData = true.obs;
  var countAktif = 0.obs;
  var countSelesai = 0.obs;
  var recentHistory = <Map<String, dynamic>>[].obs;
  var userName = 'Memuat...'.obs;

  // ✅ Observable untuk mengecek kelengkapan profil
  var isProfileIncomplete = false.obs;

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

      if (userId == null) return;

      // 2. Ambil dari tabel 'profiles' dan kolom 'full_name', 'nomor_telepon'
      final userRes = await supabase
          .from('profiles')
          .select('full_name, nomor_telepon')
          .eq('id', userId)
          .maybeSingle();

      if (userRes != null) {
        if (userRes['full_name'] != null) {
          userName.value = userRes['full_name'];
        }
      }

      // 3. Cek Kelengkapan Profil di tabel 'masyarakat'
      final masyarakatRes = await supabase
          .from('masyarakat')
          .select('nik, alamat, id_kabupaten, id_kecamatan, id_kelurahan')
          .eq('id', userId)
          .maybeSingle();

      // Logika Pengecekan: Jika data masyarakat null, atau salah satu kolom penting null
      bool incomplete = false;

      if (masyarakatRes == null) {
        incomplete = true;
      } else {
        // Cek kolom di tabel masyarakat
        if (masyarakatRes['nik'] == null ||
            masyarakatRes['alamat'] == null ||
            masyarakatRes['id_kabupaten'] == null ||
            masyarakatRes['id_kecamatan'] == null ||
            masyarakatRes['id_kelurahan'] == null) {
          incomplete = true;
        }
        // Cek nomor_telepon di tabel profiles
        if (userRes?['nomor_telepon'] == null) {
          incomplete = true;
        }
      }

      isProfileIncomplete.value = incomplete;

      // 4. Ambil Data Pengaduan (Disesuaikan dengan nama kolom asli)
      final List<dynamic> allPengaduan = await supabase
          .from('pengaduan')
          .select('id_pengaduan, status, jenis_masalah, judul_pengaduan, created_at')
          .eq('masyarakat_id', userId)
          .order('created_at', ascending: false);

      int aktif = 0, selesai = 0;

      for (final item in allPengaduan) {
        final status = (item['status']?.toString() ?? '').toLowerCase().trim();

        // Kasus Aktif = diproses (sesuai ENUM database)
        if (status == 'diproses') {
          aktif++;
        } else if (status == 'selesai') {
          selesai++;
        }
      }

      countAktif.value = aktif;
      countSelesai.value = selesai;

      // Ambil 3 data teratas untuk Riwayat Terbaru
      recentHistory.assignAll(
          allPengaduan.take(3).map((e) => e as Map<String, dynamic>).toList());
    } catch (e) {
      print('❌ Error dashboard masyarakat: $e');
    } finally {
      isLoadingData.value = false;
    }
  }
}
