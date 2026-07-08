import 'package:get/get.dart';
import '../../daftar_chat_paralegal/controllers/daftar_chat_paralegal_controller.dart';

class ParalegalDashboardController extends GetxController {
  // Default ke tab Home (Index 2)
  var selectedIndex = 2.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
    if (index == 3) {
      try {
        if (Get.isRegistered<DaftarChatParalegalController>()) {
          Get.find<DaftarChatParalegalController>().fetchDaftarChatParalegal();
        }
      } catch (e) {
        // Silently catch if not registered yet
      }
    }
  }
}