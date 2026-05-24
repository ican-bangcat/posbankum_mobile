import 'package:get/get.dart';

class InfoChatPosbankumController extends GetxController {
  // Variabel untuk Switch Bisukan Notifikasi
  var isMuted = false.obs;

  void toggleMute(bool value) {
    isMuted.value = value;
  }
}