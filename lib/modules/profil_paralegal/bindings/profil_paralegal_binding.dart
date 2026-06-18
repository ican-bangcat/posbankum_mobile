import 'package:get/get.dart';
import '../controllers/profil_paralegal_controller.dart';

class ProfilParalegalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfilParalegalController>(
          () => ProfilParalegalController(),
    );
  }
}