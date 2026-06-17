import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio_pkg;
import '../../../app/data/services/api_service.dart';
import 'profile_controller.dart';

class EditProfileController extends GetxController {
  final ApiService _apiService = ApiService();

  // --- CONTROLLER UNTUK TEKS ---
  final namaC = TextEditingController();
  final nikC = TextEditingController();
  final emailC = TextEditingController();
  final noHpC = TextEditingController();
  final alamatDetailC = TextEditingController();

  // --- VARIABEL REAKTIF UI ---
  var displayNama = 'Memuat...'.obs;
  var avatarUrl = ''.obs;
  var isLoadingData = true.obs;

  // --- VARIABEL UNTUK UPLOAD FOTO ---
  var selectedImageBytes = Rxn<Uint8List>();
  String? selectedImageExt;

  // --- VARIABEL REAKTIF UNTUK DROPDOWN WILAYAH ---
  var listKabupaten = [].obs;
  var listKecamatan = [].obs;
  var listKelurahan = [].obs;

  var selectedKabupatenId = Rxn<String>();
  var selectedKecamatanId = Rxn<String>();
  var selectedKelurahanId = Rxn<String>();

  var isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchKabupaten();
    fetchUserData();
  }

  // 0. AMBIL DATA USER
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
        displayNama.value = userData['nama_lengkap'] ?? 'Pengguna';

        // Ambil data kependudukan masyarakat jika role-nya warga
        if (userData['masyarakat'] != null) {
          final msk = userData['masyarakat'];
          nikC.text = msk['nik'] ?? '';
          alamatDetailC.text = msk['alamat'] ?? '';

          // Handle Dropdowns (UUID/String dari Laravel)
          if (msk['id_kabupaten'] != null) {
            selectedKabupatenId.value = msk['id_kabupaten'].toString();
            await fetchKecamatan(selectedKabupatenId.value!);

            if (msk['id_kecamatan'] != null) {
              selectedKecamatanId.value = msk['id_kecamatan'].toString();
              await fetchKelurahan(selectedKecamatanId.value!);

              if (msk['id_kelurahan'] != null) {
                selectedKelurahanId.value = msk['id_kelurahan'].toString();
              }
            }
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data profil: $e');
    } finally {
      isLoadingData.value = false;
    }
  }

  // 1. AMBIL KABUPATEN
  Future<void> fetchKabupaten() async {
    try {
      final response = await _apiService.dio.get('/wilayah/kabupaten');
      if (response.data['status'] == true) {
        listKabupaten.value = response.data['data'] ?? [];
      }
    } catch (e) {
      debugPrint('Error fetchKabupaten: $e');
    }
  }

  // 2. AMBIL KECAMATAN
  Future<void> fetchKecamatan(String kabId) async {
    try {
      if (selectedKecamatanId.value != null && !isLoadingData.value) {
        selectedKecamatanId.value = null;
        selectedKelurahanId.value = null;
        listKelurahan.clear();
      }
      final response = await _apiService.dio.get(
        '/wilayah/kecamatan',
        queryParameters: {'id_kabupaten': kabId},
      );
      if (response.data['status'] == true) {
        listKecamatan.value = response.data['data'] ?? [];
      }
    } catch (e) {
      debugPrint('Error fetchKecamatan: $e');
    }
  }

  // 3. AMBIL KELURAHAN
  Future<void> fetchKelurahan(String kecId) async {
    try {
      if (selectedKelurahanId.value != null && !isLoadingData.value) {
        selectedKelurahanId.value = null;
      }
      final response = await _apiService.dio.get(
        '/wilayah/kelurahan',
        queryParameters: {'id_kecamatan': kecId},
      );
      if (response.data['status'] == true) {
        listKelurahan.value = response.data['data'] ?? [];
      }
    } catch (e) {
      debugPrint('Error fetchKelurahan: $e');
    }
  }

  // 4. PILIH FOTO
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

  // 5. SIMPAN PROFIL
  Future<void> simpanProfil() async {
    if (namaC.text.trim().isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Nama lengkap tidak boleh kosong!',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

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
          // Tangkap URL foto baru yang dikembalikan Laravel
          finalAvatarUrl = uploadRes.data['data']['foto_profile'] ?? uploadRes.data['data']['url'];
          avatarUrl.value = finalAvatarUrl ?? '';
        } else {
          throw uploadRes.data['message'] ?? 'Gagal mengunggah foto profil ke server';
        }
      }

      // 2. Kirim Request Update Profil ke Laravel API
      final response = await _apiService.dio.put('/profile', data: {
        'nama_lengkap': namaC.text.trim(),
        'nomor_telepon': noHpC.text.trim(),
        'foto_profile': finalAvatarUrl,
        'nik': nikC.text.trim(),
        'alamat': alamatDetailC.text.trim(),
        'id_kabupaten': selectedKabupatenId.value,
        'id_kecamatan': selectedKecamatanId.value,
        'id_kelurahan': selectedKelurahanId.value,
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
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().fetchUserData();
    }
  }
}