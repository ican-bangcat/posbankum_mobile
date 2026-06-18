import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio_pkg;
import '../../../app/data/services/api_service.dart';
import 'kelola_kegiatan_controller.dart';
import '../../../app/routes/app_routes.dart';

class TambahKegiatanController extends GetxController {
  final ApiService _apiService = ApiService();
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
    fetchDataAwal();
  }

  Future<void> fetchDataAwal() async {
    try {
      final response = await _apiService.dio.get('/profile');
      if (response.data['status'] == true) {
        final userData = response.data['data'];
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

      final response = await _apiService.dio.post('/kegiatan', data: formData);

      if (response.data['status'] == true) {
        if (Get.isRegistered<KelolaKegiatanController>()) {
          Get.find<KelolaKegiatanController>().fetchKegiatan();
        }
        Get.offNamed(AppRoutes.KONFIRMASI_KEGIATAN);
      } else {
        throw response.data['message'] ?? 'Gagal menyimpan kegiatan';
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan kegiatan: $e");
    } finally {
      isLoading.value = false;
    }
  }
}