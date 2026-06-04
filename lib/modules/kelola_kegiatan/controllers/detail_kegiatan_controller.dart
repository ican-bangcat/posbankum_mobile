import 'package:flutter/material.dart'; // ✅ Wajib ditambah buat manggil Colors
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      final String? id = Get.arguments;

      if (id == null) {
        Get.snackbar("Error", "ID Kegiatan tidak ditemukan");
        return;
      }

      final response = await supabase
          .from('kegiatan')
          .select()
          .eq('id_kegiatan', id)
          .single();

      // ✅ Pastikan URL gambar jadi full HTTP sebelum masuk ke View
      if (response['thumbnail_path'] != null && !response['thumbnail_path'].toString().startsWith('http')) {
        response['thumbnail_path'] = supabase.storage
            .from('kegiatan-thumbnails')
            .getPublicUrl(response['thumbnail_path']);
      }

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
    // ✅ Format jam dibuang karena kita pakai pure tanggal
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dt);
  }

  // ✅ Helper untuk warna status dinamis
  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'disetujui':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      case 'menunggu':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}