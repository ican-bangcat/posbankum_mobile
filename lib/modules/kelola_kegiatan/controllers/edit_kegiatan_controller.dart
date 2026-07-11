import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio_pkg;
import '../models/kegiatan_model.dart';
import '../repositories/kegiatan_repository.dart';
import 'kelola_kegiatan_controller.dart';
import 'detail_kegiatan_controller.dart';

class EditKegiatanController extends GetxController {
  final KegiatanRepository _repository;
  var kegiatanId = '';
  var existingImageUrl = ''.obs;

  final judulCtrl = TextEditingController();
  final lokasiCtrl = TextEditingController();
  final deskripsiCtrl = TextEditingController();
  final hasilCtrl = TextEditingController();

  var selectedDate = Rxn<DateTime>();
  var selectedImage = Rxn<File>();
  var isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();

  EditKegiatanController({KegiatanRepository? repository})
      : _repository = repository ?? KegiatanRepository();

  @override
  void onInit() {
    super.onInit();
    kegiatanId = Get.arguments as String;
    fetchDataAwal();
  }

  Future<void> fetchDataAwal() async {
    try {
      isLoading.value = true;

      final KegiatanItem item = await _repository.fetchDetailKegiatan(kegiatanId);

      judulCtrl.text = item.judul;
      lokasiCtrl.text = item.lokasi;
      deskripsiCtrl.text = item.deskripsi ?? '';
      hasilCtrl.text = item.hasilKegiatan ?? '';
      existingImageUrl.value = item.imageUrl ?? '';

      if (item.tglMulai != null) {
        selectedDate.value = DateTime.parse(item.tglMulai!).toLocal();
      }

    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data awal: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ KOMPRESI GAMBAR ALA WHATSAPP
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 1080,
    );

    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (date != null) selectedDate.value = date;
  }

  Future<void> updateKegiatan() async {
    if (judulCtrl.text.isEmpty || selectedDate.value == null || lokasiCtrl.text.isEmpty) {
      Get.snackbar("Error", "Mohon lengkapi form yang wajib!");
      return;
    }

    try {
      isLoading.value = true;
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value!);

      final Map<String, dynamic> dataMap = {
        '_method': 'PUT',
        'judul': judulCtrl.text,
        'tgl_mulai': formattedDate,
        'lokasi': lokasiCtrl.text,
        'deskripsi': deskripsiCtrl.text,
        'hasil_kegiatan': hasilCtrl.text,
        'jumlah_peserta': null,
        'anggota_terlibat': null,
        'thumbnail_path': existingImageUrl.value,
        'status': 'menunggu',
      };

      if (selectedImage.value != null) {
        dataMap['thumbnail_path'] = await dio_pkg.MultipartFile.fromFile(
          selectedImage.value!.path,
          filename: selectedImage.value!.path.split('/').last,
        );
      }

      final formData = dio_pkg.FormData.fromMap(dataMap);

      final success = await _repository.updateKegiatan(kegiatanId, formData);

      if (success) {
        if (Get.isRegistered<KelolaKegiatanController>()) Get.find<KelolaKegiatanController>().fetchKegiatan();
        if (Get.isRegistered<DetailKegiatanController>()) Get.find<DetailKegiatanController>().fetchDetailKegiatan();

        Get.back();
        Get.snackbar("Berhasil", "Kegiatan diperbarui & masuk antrean persetujuan!", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        throw 'Gagal memperbarui kegiatan';
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal memperbarui kegiatan: $e");
    } finally {
      isLoading.value = false;
    }
  }
}