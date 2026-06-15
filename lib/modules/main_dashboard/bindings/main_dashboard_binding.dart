import 'package:get/get.dart';
import '../controllers/main_dashboard_controller.dart';
import '../../pengaduan/controllers/riwayat_pengaduan_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../pengaduan/controllers/daftar_pengaduan_controller.dart';
import '../../notifikasi_masyarakat/controllers/notifikasi_masyarakat_controller.dart';
import '../../daftar_chat_masyarakat/controllers/daftar_chat_masyarakat_controller.dart';

class MainDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Controller untuk Navbar Utama
    Get.lazyPut<MainDashboardController>(() => MainDashboardController());

    // 2. Controller untuk Riwayat Pengaduan
    Get.lazyPut<RiwayatPengaduanController>(() => RiwayatPengaduanController());

    // 3. Controller untuk Profile
    Get.lazyPut<ProfileController>(() => ProfileController());

    // 4. Controller untuk Tab-Tab Lain (Agar inisialisasi bersih)
    Get.lazyPut<DaftarPengaduanController>(() => DaftarPengaduanController());
    Get.lazyPut<NotifikasiMasyarakatController>(() => NotifikasiMasyarakatController());
    Get.lazyPut<DaftarChatMasyarakatController>(() => DaftarChatMasyarakatController());
  }
}
