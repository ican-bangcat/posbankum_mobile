import 'package:get/get.dart';
import '../controllers/detail_kegiatan_controller.dart';

class DetailKegiatanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailKegiatanController>(
          () => DetailKegiatanController(),
    );
  }
}