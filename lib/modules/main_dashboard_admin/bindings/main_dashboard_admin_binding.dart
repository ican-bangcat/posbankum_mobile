import 'package:get/get.dart';
import '../controllers/main_dashboard_admin_controller.dart';
// import '../../auth/controllers/home_paralegal_controller.dart'; // (Kalau ada controllernya)
import '../../kelola_kegiatan/controllers/kelola_kegiatan_controller.dart';
class MainDashboardAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainDashboardAdminController>(
          () => MainDashboardAdminController(),
    );

    // ✅ Tambahin baris ini! Biar pas tab Kegiatan diklik, datanya udah siap.
    Get.lazyPut<KelolaKegiatanController>(
          () => KelolaKegiatanController(),
    );
  }
}