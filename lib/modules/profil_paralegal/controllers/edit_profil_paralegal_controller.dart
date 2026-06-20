import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio_pkg;
import '../../../app/data/services/api_service.dart';
import 'profil_paralegal_controller.dart';

class EditProfilParalegalController extends GetxController {
  final ApiService _apiService = ApiService();

  // --- CONTROLLER UNTUK TEKS ---
  final namaC = TextEditingController();
  final emailC = TextEditingController();
  final noHpC = TextEditingController();

  // --- VARIABEL REAKTIF UI ---
  var displayNama = 'Memuat...'.obs;
  var avatarUrl = ''.obs;
  var posbankumName = ''.obs;
  var isLoadingData = true.obs;

  // --- VARIABEL UNTUK UPLOAD FOTO ---
  var selectedImageBytes = Rxn<Uint8List>();
  String? selectedImageExt;

  var isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  // AMBIL DATA USER
  Future<void> fetchUserData() async {
    try {
      isLoadingData.value = true;

      final response = await _apiService.dio.get('/profile');
      if (response.data['status'] == true) {
        final userData = response.data['data'];

        emailC.text = userData['email'] ?? '';
        namaC.text = userData['nama_lengkap'] ?? '';
        noHpC.text = userData['nomor_telepon'] ?? '';
        avatarUrl.value = userData['foto_profile'] ?? '';
        displayNama.value = userData['nama_lengkap'] ?? 'Paralegal';

        if (userData['posbankum'] != null) {
          posbankumName.value = userData['posbankum']['nama_posbankum'] ?? '-';
        } else {
          posbankumName.value = 'Belum ditugaskan';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data profil: $e');
    } finally {
      isLoadingData.value = false;
    }
  }

  // PILIH FOTO
  Future<void> pickFoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        selectedImageBytes.value = await image.readAsBytes();
        selectedImageExt = image.name.split('.').last;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih foto: $e');
    }
  }

  // SIMPAN PROFIL
  Future<void> simpanProfil() async {
    try {
      isSaving.value = true;
      String? finalAvatarUrl = avatarUrl.value;

      // 1. Upload Foto Profil Terlebih Dahulu (Jika Ada)
      if (selectedImageBytes.value != null && selectedImageExt != null) {
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.$selectedImageExt';
        
        final dio_pkg.FormData formData = dio_pkg.FormData.fromMap({
          'foto': dio_pkg.MultipartFile.fromBytes(
            selectedImageBytes.value!,
            filename: fileName,
          ),
        });

        final uploadRes = await _apiService.dio.post(
          '/upload/foto-profil',
          data: formData,
        );

        if (uploadRes.data['status'] == true) {
          finalAvatarUrl = uploadRes.data['data']['foto_profile'] ?? uploadRes.data['data']['url'];
          avatarUrl.value = finalAvatarUrl ?? '';
        } else {
          throw uploadRes.data['message'] ?? 'Gagal mengunggah foto profil';
        }
      }

      // 2. Kirim Request Update Profil ke Laravel API
      final response = await _apiService.dio.put('/profile', data: {
        'nama_lengkap': namaC.text.trim(),
        'nomor_telepon': noHpC.text.trim(),
        'foto_profile': finalAvatarUrl,
      });

      if (response.data['status'] == true) {
        refreshProfileData();
        Get.back();
        Get.snackbar(
          'Sukses',
          'Profil berhasil diperbarui!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw response.data['message'] ?? 'Gagal memperbarui data profil';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan profil: $e',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  void refreshProfileData() {
    if (Get.isRegistered<ProfilParalegalController>()) {
      Get.find<ProfilParalegalController>().fetchProfilDariWeb();
    }
  }
}
