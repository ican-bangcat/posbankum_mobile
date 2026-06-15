import 'package:get/get.dart';
import '../controllers/main_dashboard_admin_controller.dart';
import '../../kelola_kegiatan/controllers/kelola_kegiatan_controller.dart';
import '../../kelola_pengaduan/controllers/kelola_pengaduan_controller.dart';
import '../../auth/controllers/home_paralegal_controller.dart';
import '../../daftar_chat_paralegal/controllers/daftar_chat_paralegal_controller.dart';
import '../../profil_posbankum/controllers/profil_posbankum_controller.dart';

class MainDashboardAdminBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Controller untuk Navbar Utama Admin
    Get.lazyPut<MainDashboardAdminController>(() => MainDashboardAdminController());

    // 2. Controller untuk Tab-Tab Admin
    Get.lazyPut<KelolaKegiatanController>(() => KelolaKegiatanController());
    Get.lazyPut<KelolaPengaduanController>(() => KelolaPengaduanController());
    Get.lazyPut<HomeParalegalController>(() => HomeParalegalController());
    Get.lazyPut<DaftarChatParalegalController>(() => DaftarChatParalegalController());
    Get.lazyPut<ProfilPosbankumController>(() => ProfilPosbankumController());
  }
}
