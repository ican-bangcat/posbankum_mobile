// update_progres_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'kelola_pengaduan_controller.dart';
import 'detail_kasus_paralegal_controller.dart';
import '../../auth/controllers/home_paralegal_controller.dart'; // ✅ TAMBAH IMPORT INI

class UpdateProgresController extends GetxController {
  final supabase = Supabase.instance.client;
  var isLoading = false.obs;

  String kasusId = '';
  String namaKasus = '';

  final catatanController = TextEditingController();
  var selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      kasusId = Get.arguments['id'] ?? '';
      namaKasus = Get.arguments['judul'] ?? 'Kasus';
    }
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
    if (isLoading.value) return; // ✅ Anti-spam sudah ada di sini

    if (catatanController.text.trim().isEmpty) {
      Get.snackbar('Peringatan', 'Catatan progres tidak boleh kosong!',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      await supabase.from('progres_kasus').insert({
        'pengaduan_id': kasusId,
        'deskripsi_progres': catatanController.text.trim(),
        'tanggal_progres': selectedDate.value.toIso8601String(),
      });

      if (isSelesai) {
        await supabase
            .from('pengaduan')
            .update({'status': 'selesai', 'tgl_selesai': DateTime.now().toIso8601String()})
            .eq('id', kasusId);
      }

      Get.snackbar(
        'Berhasil',
        isSelesai ? 'Kasus telah diselesaikan!' : 'Laporan progres berhasil disimpan!',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // ✅ Refresh semua controller yang terdaftar
      if (Get.isRegistered<DetailKasusParalegalController>()) {
        await Get.find<DetailKasusParalegalController>().fetchDetailKasus(kasusId);
      }
      if (Get.isRegistered<KelolaPengaduanController>()) {
        Get.find<KelolaPengaduanController>().fetchPengaduan();
      }
      // ✅ FIX PROBLEM 3: Trigger refresh Dashboard Home
      if (Get.isRegistered<HomeParalegalController>()) {
        Get.find<HomeParalegalController>().fetchDashboardData();
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        Get.back();
      });

    } catch (e) {
      print('❌ Error simpan progres: $e');
      Get.snackbar('Gagal', 'Terjadi kesalahan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}