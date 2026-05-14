import 'package:flutter/material.dart'; // ✅ Wajib ditambah buat manggil Colors
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// ✅ Import WebSupabaseService
import '../../../app/data/services/supabase_service.dart';

class DetailKegiatanController extends GetxController {
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

      // ✅ Pakai WebSupabaseService dan pakai id_kegiatan
      final response = await WebSupabaseService.client
          .from('kegiatan')
          .select()
          .eq('id_kegiatan', id)
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