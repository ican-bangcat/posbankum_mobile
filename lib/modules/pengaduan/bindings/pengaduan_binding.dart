import 'package:get/get.dart';
import '../controllers/daftar_pengaduan_controller.dart';
import '../controllers/form_pengaduan_controller.dart';
import '../controllers/riwayat_pengaduan_controller.dart';
import '../repositories/pengaduan_repository.dart';

class PengaduanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengaduanRepository>(() => PengaduanRepository());
    
    Get.lazyPut<DaftarPengaduanController>(() => DaftarPengaduanController(
      repository: Get.find<PengaduanRepository>(),
    ));
    
    Get.lazyPut<RiwayatPengaduanController>(() => RiwayatPengaduanController(
      repository: Get.find<PengaduanRepository>(),
    ));

    Get.lazyPut<FormPengaduanController>(() => FormPengaduanController(
      repository: Get.find<PengaduanRepository>(),
    ));
  }
}
