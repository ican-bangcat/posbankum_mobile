import 'package:get/get.dart';
import '../controllers/detail_kasus_controller.dart';

class DetailKasusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailKasusController>(() => DetailKasusController());
  }
}