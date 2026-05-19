import 'package:get/get.dart';
import '../controllers/notifikasi_masyarakat_controller.dart';

class NotifikasiMasyarakatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotifikasiMasyarakatController>(
      () => NotifikasiMasyarakatController(),
    );
  }
}
