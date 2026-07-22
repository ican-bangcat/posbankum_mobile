import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import '../repositories/kelola_pengaduan_repository.dart';
import 'kelola_pengaduan_controller.dart';
import 'detail_kasus_paralegal_controller.dart';
import '../../paralegal_dashboard/controllers/home_paralegal_controller.dart';
import '../../notifikasi/controllers/notifikasi_warga_controller.dart';
import '../../notifikasi/controllers/notifikasi_paralegal_controller.dart';

class UpdateProgresController extends GetxController {
  final KelolaPengaduanRepository _repository;
  var isLoading = false.obs;

  String kasusId = '';
  String namaKasus = '';

  final judulController = TextEditingController();
  final catatanController = TextEditingController();
  final selectedDate = Rxn<DateTime>();
  var selectedFiles = <File>[].obs;

  UpdateProgresController({KelolaPengaduanRepository? repository, String? initialKasusId, String? initialNamaKasus})
      : _repository = repository ?? KelolaPengaduanRepository() {
    if (initialKasusId != null) kasusId = initialKasusId;
    if (initialNamaKasus != null) namaKasus = initialNamaKasus;
  }

  @override
  void onInit() {
    super.onInit();
    if (kasusId.isEmpty && Get.arguments != null) {
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
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  Future<void> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
      );
      if (result != null) {
        for (var file in result.files) {
          if (file.size > 5 * 1024 * 1024) {
            Get.snackbar("Gagal", "File ${file.name} melebihi 5 MB.",
                backgroundColor: Colors.orange, colorText: Colors.white);
            continue;
          }
          if (file.path != null) selectedFiles.add(File(file.path!));
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil file", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void removeFileAt(int index) {
    selectedFiles.removeAt(index);
  }

  Future<void> bukaFileLokal(String path) async {
    try {
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        Get.snackbar("Info", "Tidak ada aplikasi untuk membuka file ini.");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal membuka file.");
    }
  }

  Future<void> simpanProgres({required bool isSelesai}) async {
    if (isLoading.value) return;

    if (selectedDate.value == null) {
      Get.snackbar('Peringatan', 'Tanggal pendampingan belum dipilih!',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (judulController.text.trim().isEmpty || catatanController.text.trim().isEmpty) {
      Get.snackbar('Peringatan', 'Judul dan Catatan progres tidak boleh kosong!',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // 1. Simpan progres ke timeline via Repository → dapat id_timeline
      final idTimeline = await _repository.simpanProgresTimeline(
        kasusId: kasusId,
        title: judulController.text.trim(),
        deskripsi: catatanController.text.trim(),
        tanggal: selectedDate.value!.toIso8601String(),
      );

      // 2. Upload lampiran yang terhubung ke id_timeline ini
      if (selectedFiles.isNotEmpty && idTimeline.isNotEmpty) {
        for (var file in selectedFiles) {
          try {
            final ext = file.path.split('.').last.toLowerCase();
            final fileName = 'progres_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}.$ext';
            await _repository.uploadLampiranProgres(
              kasusId: kasusId,
              idTimeline: idTimeline,
              file: file,
              fileName: fileName,
            );
          } catch (e) {
            print('❌ Gagal upload lampiran progres: $e');
          }
        }
      }

      // 3. Jika diselesaikan, update status pengaduan via Repository
      if (isSelesai) {
        await _repository.updateStatusKasus(
          kasusId: kasusId,
          status: 'selesai',
          catatanInternal: catatanController.text.trim(),
        );
      }

      // 4. Kosongkan form
      judulController.clear();
      catatanController.clear();
      selectedDate.value = null;
      selectedFiles.clear();

      // 5. Tendang balik
      Get.back();

      // 6. Notif
      Get.snackbar(
        'Berhasil',
        isSelesai ? 'Kasus telah diselesaikan!' : 'Laporan progres berhasil disimpan!',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // 7. Refresh data di background
      if (Get.isRegistered<DetailKasusParalegalController>()) {
        Get.find<DetailKasusParalegalController>().fetchDetailKasus(kasusId);
      }
      if (Get.isRegistered<KelolaPengaduanController>()) {
        Get.find<KelolaPengaduanController>().fetchPengaduan();
      }
      if (Get.isRegistered<HomeParalegalController>()) {
        Get.find<HomeParalegalController>().fetchDashboardData();
      }
      if (Get.isRegistered<NotifikasiWargaController>()) {
        Get.find<NotifikasiWargaController>().fetchNotifications();
      }
      if (Get.isRegistered<NotifikasiParalegalController>()) {
        Get.find<NotifikasiParalegalController>().fetchNotifications();
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