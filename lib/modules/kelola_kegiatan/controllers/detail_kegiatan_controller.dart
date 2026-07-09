import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/kegiatan_model.dart';
import '../repositories/kegiatan_repository.dart';

class DetailKegiatanController extends GetxController {
  final KegiatanRepository _repository;
  var isLoading = true.obs;
  var kegiatanData = Rxn<KegiatanItem>();

  DetailKegiatanController({KegiatanRepository? repository})
      : _repository = repository ?? KegiatanRepository();

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

      final item = await _repository.fetchDetailKegiatan(id);
      kegiatanData.value = item;
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