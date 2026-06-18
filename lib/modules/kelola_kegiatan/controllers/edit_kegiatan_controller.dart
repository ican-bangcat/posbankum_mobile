import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio_pkg;
import '../../../app/data/services/api_service.dart';
import 'kelola_kegiatan_controller.dart';
import 'detail_kegiatan_controller.dart';

class EditKegiatanController extends GetxController {
  final ApiService _apiService = ApiService();
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

  @override
  void onInit() {
    super.onInit();
    kegiatanId = Get.arguments as String;
    fetchDataAwal();
  }

  Future<void> fetchDataAwal() async {
    try {
      isLoading.value = true;

      final profileResponse = await _apiService.dio.get('/profile');
      if (profileResponse.data['status'] == true) {
        final userData = profileResponse.data['data'];
        idPosbankumAsli.value = userData['id_posbankum']?.toString() ?? '';

        if (idPosbankumAsli.value.isNotEmpty) {
          final posbankumResponse = await _apiService.dio.get('/posbankum/${idPosbankumAsli.value}');
          if (posbankumResponse.data['status'] == true) {
            final posbankumData = posbankumResponse.data['data'];
            final List<dynamic> listParalegalRaw = posbankumData['paralegals'] ?? posbankumData['members'] ?? [];
            paralegalList.value = listParalegalRaw.map<String>((p) {
              return (p['nama_lengkap'] ?? p['nama_paralegal'] ?? p['name'] ?? '-').toString();
            }).toList();
          }
        }
      }

      final response = await _apiService.dio.get('/kegiatan/$kegiatanId');

      if (response.data['status'] == true) {
        final data = response.data['data'];
        judulCtrl.text = data['judul'] ?? '';
        lokasiCtrl.text = data['lokasi'] ?? '';
        deskripsiCtrl.text = data['deskripsi'] ?? '';
        jmlPesertaCtrl.text = (data['jumlah_peserta'] ?? '').toString();
        existingImageUrl.value = data['thumbnail_path'] ?? '';

        if (data['tgl_mulai'] != null) {
          selectedDate.value = DateTime.parse(data['tgl_mulai']).toLocal();
        }

        if (data['anggota_terlibat'] != null) {
          if (data['anggota_terlibat'] is List) {
            List<dynamic> rawAnggota = data['anggota_terlibat'];
            selectedParalegals.value = rawAnggota.map((e) => e.toString()).toList();
          } else if (data['anggota_terlibat'] is String) {
            // fallback
          }
        }
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

      final response = await _apiService.dio.post(
        '/kegiatan/$kegiatanId',
        data: formData,
      );

      if (response.data['status'] == true) {
        if (Get.isRegistered<KelolaKegiatanController>()) Get.find<KelolaKegiatanController>().fetchKegiatan();
        if (Get.isRegistered<DetailKegiatanController>()) Get.find<DetailKegiatanController>().fetchDetailKegiatan();

        Get.back();
        Get.snackbar("Berhasil", "Kegiatan diperbarui & masuk antrean persetujuan!", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        throw response.data['message'] ?? 'Gagal memperbarui kegiatan';
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal memperbarui kegiatan: $e");
    } finally {
      isLoading.value = false;
    }
  }
}