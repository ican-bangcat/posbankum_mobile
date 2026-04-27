import 'package:get/get.dart';
import '../controllers/edit_kegiatan_controller.dart';

class EditKegiatanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditKegiatanController>(() => EditKegiatanController());
  }
}