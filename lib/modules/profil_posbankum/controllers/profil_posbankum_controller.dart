import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/data/services/supabase_service.dart';

class ProfilPosbankumController extends GetxController {

  var isLoading = true.obs;

  var namaPosbankum = ''.obs;
  var email = ''.obs;
  var kabupaten = ''.obs;
  var kecamatan = ''.obs;
  var kelurahan = ''.obs;
  var alamat = ''.obs;
  var kodePos = ''.obs;
  var jmlParalegal = 0.obs;

  var paralegalList = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfilDariWeb();
  }

  Future<void> fetchProfilDariWeb() async {
    try {
      isLoading.value = true;

      // 1. Ambil User yang sedang login dari Pintu Samping (Web)
      final user = WebSupabaseService.client.auth.currentUser;

      if (user == null) {
        Get.snackbar('Sesi Berakhir', 'Silakan login kembali');
        return;
      }

      final String userEmail = user.email ?? '';

      if (userEmail.isEmpty) {
        Get.snackbar('Error Data', 'Email akun tidak ditemukan pada sesi login ini.');
        return;
      }

      // 🔵 2. NARIK DATA POSBANKUM + JOIN KABUPATEN & KECAMATAN
      final dataPosbankum = await WebSupabaseService.client
          .from('posbankum')
      // ✅ SIHIR JOIN: Cukup tambahkan nama_tabel (nama_kolom)
          .select('''
            id_posbankum, 
            nama, 
            email_akun, 
            kelurahan, 
            alamat, 
            kode_pos, 
            jml_paralegal,
            kabupaten (nama),
            kecamatan (nama)
          ''')
          .eq('email_akun', userEmail)
          .maybeSingle();

      if (dataPosbankum != null) {
        final String idPosbankumAsli = dataPosbankum['id_posbankum'];

        // 🔵 3. NARIK DATA PARALEGAL
        final dataParalegal = await WebSupabaseService.client
            .from('paralegal_members')
            .select('nama_paralegal, nomor_telepon, is_primary')
            .eq('id_posbankum', idPosbankumAsli)
            .order('is_primary', ascending: false);

        // 🟢 4. MASUKKAN KE UI
        namaPosbankum.value = dataPosbankum['nama'] ?? '';
        email.value = dataPosbankum['email_akun'] ?? '';
        kelurahan.value = dataPosbankum['kelurahan'] ?? '';
        alamat.value = dataPosbankum['alamat'] ?? '';
        kodePos.value = dataPosbankum['kode_pos'] ?? '';

        // ✅ CARA MENGAMBIL DATA DARI HASIL JOIN
        // Karena datanya bersarang (nested JSON), kita panggil nama tabelnya dulu, baru nama kolomnya
        kabupaten.value = dataPosbankum['kabupaten']?['nama'] ?? '';
        kecamatan.value = dataPosbankum['kecamatan']?['nama'] ?? '';

        jmlParalegal.value = dataPosbankum['jml_paralegal'] != null
            ? int.tryParse(dataPosbankum['jml_paralegal'].toString()) ?? 0
            : 0;

        if (dataParalegal != null) {
          paralegalList.value = dataParalegal;
        }

      } else {
        print("⚠ Peringatan: Data Posbankum tidak ditemukan untuk Email: $userEmail");
      }

    } catch (e) {
      Get.snackbar('Error Koneksi Web', 'Gagal menarik data: $e');
      print('Error detail: $e');
    } finally {
      isLoading.value = false;
    }
  }
}