import 'package:get/get.dart';
import '../controllers/tambah_kegiatan_controller.dart';

class TambahKegiatanBinding extends Bindings {
  @override
  void dependencies() {
    // Daftarin controller tambah kegiatan ke memori
    Get.lazyPut<TambahKegiatanController>(
          () => TambahKegiatanController(),
    );
  }
}