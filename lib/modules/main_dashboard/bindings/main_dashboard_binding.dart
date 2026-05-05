import 'package:get/get.dart';
import '../controllers/main_dashboard_controller.dart';
import '../../riwayatPengaduan/controllers/riwayat_pengaduan_controller.dart';
import '../../profile/controllers/profile_controller.dart'; // ✅ Tambah Import Profile Controller

class MainDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Controller untuk Navbar Utama
    Get.lazyPut<MainDashboardController>(() => MainDashboardController());

    // 2. Controller untuk Riwayat Pengaduan
    Get.lazyPut<RiwayatPengaduanController>(() => RiwayatPengaduanController());

    // 3. Controller untuk Profile (✅ Tambahkan ini)
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}