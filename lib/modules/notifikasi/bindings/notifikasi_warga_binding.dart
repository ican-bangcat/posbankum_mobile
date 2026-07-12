import 'package:get/get.dart';
import '../controllers/notifikasi_warga_controller.dart';
import '../repositories/notifikasi_repository.dart';

class NotifikasiWargaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotifikasiRepository>(() => NotifikasiRepository());
    Get.lazyPut<NotifikasiWargaController>(() => NotifikasiWargaController());
  }
}
