import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DetailKegiatanController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = true.obs;
  var kegiatanData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDetailKegiatan();
  }

  Future<void> fetchDetailKegiatan() async {
    try {
      isLoading.value = true;
      // Tangkap ID yang dikirim dari halaman sebelumnya
      final String? id = Get.arguments;

      if (id == null) {
        Get.snackbar("Error", "ID Kegiatan tidak ditemukan");
        return;
      }

      final response = await supabase
          .from('kegiatan')
          .select()
          .eq('id', id)
          .single();

      kegiatanData.value = response;

    } catch (e) {
      print("Error fetch detail: $e");
      Get.snackbar("Error", "Gagal memuat detail kegiatan");
    } finally {
      isLoading.value = false;
    }
  }

  // Helper untuk format tanggal
  String getFormattedDate(String? rawDate) {
    if (rawDate == null) return '-';
    final dt = DateTime.parse(rawDate).toLocal();
    return DateFormat('EEEE, dd MMMM yyyy • HH:mm', 'id_ID').format(dt) + " WIB";
  }
}