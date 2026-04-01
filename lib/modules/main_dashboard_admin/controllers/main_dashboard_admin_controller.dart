import 'package:get/get.dart';

class MainDashboardAdminController extends GetxController {
  // Default ke tab Home (Index 2)
  var selectedIndex = 2.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}