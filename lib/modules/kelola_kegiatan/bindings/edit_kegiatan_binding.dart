import 'package:get/get.dart';
import '../controllers/edit_kegiatan_controller.dart';
import '../repositories/kegiatan_repository.dart';

class EditKegiatanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KegiatanRepository>(() => KegiatanRepository());
    Get.lazyPut<EditKegiatanController>(
      () => EditKegiatanController(repository: Get.find<KegiatanRepository>()),
    );
  }
}