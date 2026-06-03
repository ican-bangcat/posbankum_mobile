import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainDashboardController extends GetxController {
  final supabase = Supabase.instance.client;

  // Bikin index default 2 (Home)
  var selectedIndex = 2.obs;

  // --- State Kelengkapan Profil ---
  var isNamaComplete = false.obs;
  var isNikComplete = false.obs;
  var isTeleponComplete = false.obs;
  var isAlamatComplete = false.obs;
  var isProfileChecking = false.obs;

  bool get isAllComplete =>
      isNamaComplete.value &&
      isNikComplete.value &&
      isTeleponComplete.value &&
      isAlamatComplete.value;

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  Future<void> checkProfileCompleteness() async {
    try {
      isProfileChecking.value = true;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // 1. Cek di tabel profiles
      final profileRes = await supabase
          .from('profiles')
          .select('full_name, nomor_telepon')
          .eq('id', userId)
          .maybeSingle();

      if (profileRes != null) {
        isNamaComplete.value = profileRes['full_name'] != null;
        isTeleponComplete.value = profileRes['nomor_telepon'] != null;
      }

      // 2. Cek di tabel masyarakat
      final masyarakatRes = await supabase
          .from('masyarakat')
          .select('nik, alamat, id_kabupaten, id_kecamatan, id_kelurahan')
          .eq('id', userId)
          .maybeSingle();

      if (masyarakatRes != null) {
        isNikComplete.value = masyarakatRes['nik'] != null;
        isAlamatComplete.value = (masyarakatRes['alamat'] != null &&
            masyarakatRes['id_kabupaten'] != null &&
            masyarakatRes['id_kecamatan'] != null &&
            masyarakatRes['id_kelurahan'] != null);
      }
    } catch (e) {
      print('Error checking profile completeness: $e');
    } finally {
      isProfileChecking.value = false;
    }
  }
}
