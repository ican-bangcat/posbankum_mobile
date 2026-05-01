import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // lazyPut bikin controller baru dibuat saat benar-benar dipanggil di UI
    Get.lazyPut<ProfileController>(
          () => ProfileController(),
    );
  }
}