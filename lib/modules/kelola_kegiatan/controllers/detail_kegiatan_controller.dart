import 'package:flutter/material.dart'; // ✅ Wajib ditambah buat manggil Colors
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/data/services/api_service.dart';

class DetailKegiatanController extends GetxController {
  final ApiService _apiService = ApiService();
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

      final response = await _apiService.dio.get('/kegiatan/$id');

      if (response.data['status'] == true) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(response.data['data']);

        // ✅ Pastikan URL gambar jadi full HTTP sebelum masuk ke View
        String? finalImageUrl = data['thumbnail_path'];
        if (finalImageUrl != null && finalImageUrl.isNotEmpty && !finalImageUrl.startsWith('http')) {
          if (finalImageUrl.startsWith('/')) {
            data['thumbnail_path'] = 'http://sibapak.pocari.id$finalImageUrl';
          } else {
            data['thumbnail_path'] = 'http://sibapak.pocari.id/$finalImageUrl';
          }
        }

        kegiatanData.value = data;
      } else {
        throw response.data['message'] ?? 'Gagal memuat detail kegiatan';
      }

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