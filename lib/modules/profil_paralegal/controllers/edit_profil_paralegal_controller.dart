import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio_pkg;
import '../../profile/repositories/profile_repository.dart';
import 'profil_paralegal_controller.dart';

class EditProfilParalegalController extends GetxController {
  final ProfileRepository _profileRepository;

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

  EditProfilParalegalController({ProfileRepository? profileRepository})
      : _profileRepository = profileRepository ?? ProfileRepository();

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  // AMBIL DATA USER
  Future<void> fetchUserData() async {
    try {
      isLoadingData.value = true;

      final userData = await _profileRepository.fetchProfile();
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

        final uploadData = await _profileRepository.uploadFotoProfil(formData);
        finalAvatarUrl = uploadData['foto_profile'] ?? uploadData['url'];
        avatarUrl.value = finalAvatarUrl ?? '';
      }

      // 2. Kirim Request Update Profil ke Laravel API
      await _profileRepository.updateProfile({
        'nama_lengkap': namaC.text.trim(),
        'nomor_telepon': noHpC.text.trim(),
        'foto_profile': finalAvatarUrl,
      });

      refreshProfileData();
      Get.back();
      Get.snackbar(
        'Sukses',
        'Profil berhasil diperbarui!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
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
