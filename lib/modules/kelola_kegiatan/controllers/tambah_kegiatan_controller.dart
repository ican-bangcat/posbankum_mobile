import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio_pkg;
import '../repositories/kegiatan_repository.dart';
import 'kelola_kegiatan_controller.dart';
import '../../../app/routes/app_routes.dart';

class TambahKegiatanController extends GetxController {
  final KegiatanRepository _repository;
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

  TambahKegiatanController({KegiatanRepository? repository})
      : _repository = repository ?? KegiatanRepository();

  @override
  void onInit() {
    super.onInit();
    fetchDataAwal();
  }

  Future<void> fetchDataAwal() async {
    try {
      final userData = await _repository.fetchProfile();
      idPosbankumAsli.value = userData['id_posbankum']?.toString() ?? '';

      if (idPosbankumAsli.value.isNotEmpty) {
        final posbankumData = await _repository.fetchPosbankum(idPosbankumAsli.value);
        final List<dynamic> listParalegalRaw = posbankumData['paralegals'] ?? posbankumData['members'] ?? [];
        paralegalList.value = listParalegalRaw.map<String>((p) {
          return (p['nama_lengkap'] ?? p['nama_paralegal'] ?? p['name'] ?? '-').toString();
        }).toList();
      }
    } catch (e) {
      print("Error fetch paralegal: $e");
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
      imageQuality: 50, // Kualitas foto dikompres jadi 50%
      maxWidth: 1080,   // Lebar maksimal 1080px
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

  Future<void> simpanKegiatan() async {
    if (judulCtrl.text.isEmpty || selectedDate.value == null || lokasiCtrl.text.isEmpty) {
      Get.snackbar("Error", "Mohon isi Judul, Tanggal, dan Lokasi!");
      return;
    }

    try {
      isLoading.value = true;
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value!);

      final Map<String, dynamic> dataMap = {
        'judul': judulCtrl.text,
        'deskripsi': deskripsiCtrl.text,
        'lokasi': lokasiCtrl.text,
        'status': 'menunggu',
        'tgl_mulai': formattedDate,
        'jumlah_peserta': jmlPesertaCtrl.text.isNotEmpty ? int.tryParse(jmlPesertaCtrl.text) : null,
        'anggota_terlibat': selectedParalegals.toList(),
      };

      if (selectedImage.value != null) {
        dataMap['thumbnail_path'] = await dio_pkg.MultipartFile.fromFile(
          selectedImage.value!.path,
          filename: selectedImage.value!.path.split('/').last,
        );
      }

      final formData = dio_pkg.FormData.fromMap(dataMap);

      final success = await _repository.simpanKegiatan(formData);

      if (success) {
        if (Get.isRegistered<KelolaKegiatanController>()) {
          Get.find<KelolaKegiatanController>().fetchKegiatan();
        }
        Get.offNamed(AppRoutes.KONFIRMASI_KEGIATAN);
      } else {
        throw 'Gagal menyimpan kegiatan';
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan kegiatan: $e");
    } finally {
      isLoading.value = false;
    }
  }
}