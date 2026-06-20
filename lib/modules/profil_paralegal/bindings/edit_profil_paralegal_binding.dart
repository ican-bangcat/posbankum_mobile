import 'package:get/get.dart';
import '../controllers/edit_profil_paralegal_controller.dart';

class EditProfilParalegalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfilParalegalController>(
      () => EditProfilParalegalController(),
    );
  }
}
