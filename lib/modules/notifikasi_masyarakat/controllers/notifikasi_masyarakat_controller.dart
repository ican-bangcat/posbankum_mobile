import 'package:get/get.dart';

class NotifikasiMasyarakatController extends GetxController {
  // 0: Semua, 1: Belum Dibaca, 2: Sudah Dibaca
  final selectedFilter = 0.obs;

  void changeFilter(int index) {
    selectedFilter.value = index;
  }
}
