import 'package:get/get.dart';
import '../controllers/detail_kegiatan_controller.dart';
import '../repositories/kegiatan_repository.dart';

class DetailKegiatanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KegiatanRepository>(() => KegiatanRepository());
    Get.lazyPut<DetailKegiatanController>(
      () => DetailKegiatanController(repository: Get.find<KegiatanRepository>()),
    );
  }
}