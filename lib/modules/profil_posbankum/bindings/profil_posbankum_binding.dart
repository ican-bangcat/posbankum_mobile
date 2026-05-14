import 'package:get/get.dart';
import '../controllers/profil_posbankum_controller.dart';

class ProfilPosbankumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfilPosbankumController>(
          () => ProfilPosbankumController(),
    );
  }
}