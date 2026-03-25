import 'package:get/get.dart';

class MainDashboardController extends GetxController {
  // Bikin index default 1 (yang aktif tab Pengaduan dulu buat ngetes)
  var selectedIndex = 2.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}