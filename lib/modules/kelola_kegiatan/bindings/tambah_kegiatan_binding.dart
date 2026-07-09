import 'package:get/get.dart';
import '../controllers/tambah_kegiatan_controller.dart';
import '../repositories/kegiatan_repository.dart';

class TambahKegiatanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KegiatanRepository>(() => KegiatanRepository());
    Get.lazyPut<TambahKegiatanController>(
      () => TambahKegiatanController(repository: Get.find<KegiatanRepository>()),
    );
  }
}