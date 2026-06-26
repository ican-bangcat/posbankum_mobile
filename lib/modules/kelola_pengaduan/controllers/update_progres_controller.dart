import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/kelola_pengaduan_repository.dart';
import 'kelola_pengaduan_controller.dart';
import 'detail_kasus_paralegal_controller.dart';
import '../../paralegal_dashboard/controllers/home_paralegal_controller.dart';

class UpdateProgresController extends GetxController {
  final KelolaPengaduanRepository _repository;
  var isLoading = false.obs;

  String kasusId = '';
  String namaKasus = '';

  final judulController = TextEditingController();
  final catatanController = TextEditingController();
  var selectedDate = DateTime.now().obs;

  UpdateProgresController({KelolaPengaduanRepository? repository})
      : _repository = repository ?? KelolaPengaduanRepository();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      kasusId = Get.arguments['id'] ?? '';
      namaKasus = Get.arguments['judul'] ?? 'Kasus';
    }
  }

  @override
  void onClose() {
    judulController.dispose();
    catatanController.dispose();
    super.onClose();
  }

  Future<void> pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }

  Future<void> simpanProgres({required bool isSelesai}) async {
    if (isLoading.value) return;

    if (judulController.text.trim().isEmpty || catatanController.text.trim().isEmpty) {
      Get.snackbar('Peringatan', 'Judul dan Catatan progres tidak boleh kosong!',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // 1. Simpan progres ke timeline via Repository
      await _repository.simpanProgresTimeline(
        kasusId: kasusId,
        title: judulController.text.trim(),
        deskripsi: catatanController.text.trim(),
        tanggal: selectedDate.value.toIso8601String(),
      );

      // 2. Jika diselesaikan, update status pengaduan via Repository
      if (isSelesai) {
        await _repository.updateStatusKasus(
          kasusId: kasusId,
          status: 'selesai',
          catatanInternal: catatanController.text.trim(),
        );
      }

      // 1. Kosongkan form biar bersih
      judulController.clear();
      catatanController.clear();
      selectedDate.value = DateTime.now();

      // 2. 🚀 TENDANG BALIK DULUAN (Biar nutup halaman form)
      Get.back();

      // 3. Munculkan Notif (Akan muncul di atas layar Detail Kasus)
      Get.snackbar(
        'Berhasil',
        isSelesai ? 'Kasus telah diselesaikan!' : 'Laporan progres berhasil disimpan!',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // 4. Refresh data tanpa 'await' agar berjalan di background & tidak bikin UI nge-lag
      if (Get.isRegistered<DetailKasusParalegalController>()) {
        Get.find<DetailKasusParalegalController>().fetchDetailKasus(kasusId);
      }
      if (Get.isRegistered<KelolaPengaduanController>()) {
        Get.find<KelolaPengaduanController>().fetchPengaduan();
      }
      if (Get.isRegistered<HomeParalegalController>()) {
        Get.find<HomeParalegalController>().fetchDashboardData();
      }

    } catch (e) {
      print('❌ Error simpan progres: $e');
      Get.snackbar('Gagal', 'Terjadi kesalahan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}