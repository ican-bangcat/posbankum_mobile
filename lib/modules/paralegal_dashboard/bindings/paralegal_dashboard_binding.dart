import 'package:get/get.dart';
import '../controllers/paralegal_dashboard_controller.dart';
import '../../kelola_kegiatan/controllers/kelola_kegiatan_controller.dart';
import '../../kelola_kegiatan/repositories/kegiatan_repository.dart';
import '../../kelola_pengaduan/controllers/kelola_pengaduan_controller.dart';
import '../controllers/home_paralegal_controller.dart';
import '../../daftar_chat_paralegal/controllers/daftar_chat_paralegal_controller.dart';
import '../../profil_paralegal/controllers/profil_paralegal_controller.dart';

class ParalegalDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Controller untuk Navbar Utama Admin
    Get.lazyPut<ParalegalDashboardController>(() => ParalegalDashboardController());

    // 2. Repository Kegiatan
    Get.lazyPut<KegiatanRepository>(() => KegiatanRepository());

    // 3. Controller untuk Tab-Tab Admin
    Get.lazyPut<KelolaKegiatanController>(
      () => KelolaKegiatanController(repository: Get.find<KegiatanRepository>()),
    );
    Get.lazyPut<KelolaPengaduanController>(() => KelolaPengaduanController());
    Get.lazyPut<HomeParalegalController>(() => HomeParalegalController());
    Get.lazyPut<DaftarChatParalegalController>(() => DaftarChatParalegalController());
    Get.lazyPut<ProfilParalegalController>(() => ProfilParalegalController());
  }
}
