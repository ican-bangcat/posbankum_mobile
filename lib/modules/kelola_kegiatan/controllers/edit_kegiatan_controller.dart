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
  final jmlPesertaCtrl = TextEditingController();

  var selectedDate = Rxn<DateTime>();
  var selectedImage = Rxn<File>();
  var isLoading = false.obs;

  // VARIABEL UNTUK MULTI-SELECT PARALEGAL
  var idPosbankumAsli = ''.obs;
  var paralegalList = <String>[].obs;
  var selectedParalegals = <String>[].obs;

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

      final userData = await _repository.fetchProfile();
      idPosbankumAsli.value = userData['id_posbankum']?.toString() ?? '';

      if (idPosbankumAsli.value.isNotEmpty) {
        final posbankumData = await _repository.fetchPosbankum(idPosbankumAsli.value);
        final List<dynamic> listParalegalRaw = posbankumData['paralegals'] ?? posbankumData['members'] ?? [];
        paralegalList.value = listParalegalRaw.map<String>((p) {
          return (p['nama_lengkap'] ?? p['nama_paralegal'] ?? p['name'] ?? '-').toString();
        }).toList();
      }

      final KegiatanItem item = await _repository.fetchDetailKegiatan(kegiatanId);

      judulCtrl.text = item.judul;
      lokasiCtrl.text = item.lokasi;
      deskripsiCtrl.text = item.deskripsi ?? '';
      jmlPesertaCtrl.text = item.jumlahPeserta != null ? item.jumlahPeserta.toString() : '';
      existingImageUrl.value = item.imageUrl ?? '';

      if (item.tglMulai != null) {
        selectedDate.value = DateTime.parse(item.tglMulai!).toLocal();
      }

      if (item.anggotaTerlibat != null) {
        selectedParalegals.value = item.anggotaTerlibat!;
      }

    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data awal: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleParalegal(String nama) {
    if (selectedParalegals.contains(nama)) {
      selectedParalegals.remove(nama);
    } else {
      selectedParalegals.add(nama);
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
        'jumlah_peserta': jmlPesertaCtrl.text.isNotEmpty ? int.tryParse(jmlPesertaCtrl.text) : null,
        'anggota_terlibat': selectedParalegals.toList(),
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