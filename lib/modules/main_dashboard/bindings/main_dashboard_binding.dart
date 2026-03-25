import 'package:get/get.dart';
import '../controllers/main_dashboard_controller.dart';
// WAJIB: Masukkan binding halaman anak-anaknya ke sini supaya controllernya ikut hidup
import '../../riwayatPengaduan/controllers/riwayat_pengaduan_controller.dart';
import '../../auth/views/home_masyarakat_screen.dart';

class MainDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainDashboardController>(() => MainDashboardController());
    // Masukkan controller riwayat pengaduan di sini
    Get.lazyPut<RiwayatPengaduanController>(() => RiwayatPengaduanController());
  }
}