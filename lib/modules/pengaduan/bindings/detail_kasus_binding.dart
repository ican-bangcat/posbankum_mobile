import 'package:get/get.dart';
import '../controllers/detail_kasus_controller.dart';
import '../repositories/pengaduan_repository.dart';

class DetailKasusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengaduanRepository>(() => PengaduanRepository());
    Get.lazyPut<DetailKasusController>(() => DetailKasusController(
      repository: Get.find<PengaduanRepository>(),
    ));
  }
}