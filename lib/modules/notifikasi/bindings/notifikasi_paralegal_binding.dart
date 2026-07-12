import 'package:get/get.dart';
import '../controllers/notifikasi_paralegal_controller.dart';
import '../repositories/notifikasi_repository.dart';

class NotifikasiParalegalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotifikasiRepository>(() => NotifikasiRepository());
    Get.lazyPut<NotifikasiParalegalController>(() => NotifikasiParalegalController());
  }
}
