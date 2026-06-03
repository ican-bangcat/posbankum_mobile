import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/profile_controller.dart';

class EditProfileController extends GetxController {
  final supabase = Supabase.instance.client;

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
      final user = supabase.auth.currentUser;

      if (user != null) {
        emailC.text = user.email ?? '';

        // ✅ 1. Ambil data dari tabel profiles (Nama, No HP, Foto)
        final profileData = await supabase.from('profiles').select('*').eq('id', user.id).maybeSingle();
        if (profileData != null) {
          namaC.text = profileData['full_name'] ?? '';
          noHpC.text = profileData['nomor_telepon'] ?? '';
          avatarUrl.value = profileData['foto_profile'] ?? '';
          displayNama.value = profileData['full_name'] ?? 'Pengguna';
        }

        // ✅ 2. Ambil data dari tabel masyarakat (NIK, Alamat, Wilayah)
        final masyarakatData = await supabase.from('masyarakat').select('*').eq('id', user.id).maybeSingle();
        if (masyarakatData != null) {
          nikC.text = masyarakatData['nik'] ?? '';
          alamatDetailC.text = masyarakatData['alamat'] ?? '';

          // Handle Dropdowns (UUID)
          if (masyarakatData['id_kabupaten'] != null) {
            selectedKabupatenId.value = masyarakatData['id_kabupaten'].toString();
            await fetchKecamatan(selectedKabupatenId.value!);

            if (masyarakatData['id_kecamatan'] != null) {
              selectedKecamatanId.value = masyarakatData['id_kecamatan'].toString();
              await fetchKelurahan(selectedKecamatanId.value!);

              if (masyarakatData['id_kelurahan'] != null) {
                selectedKelurahanId.value = masyarakatData['id_kelurahan'].toString();
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
      final response = await supabase.from('kabupaten').select('id_kabupaten, nama').order('nama');
      listKabupaten.value = response;
    } catch (e) {}
  }

  // 2. AMBIL KECAMATAN
  Future<void> fetchKecamatan(String kabId) async {
    try {
      if (selectedKecamatanId.value != null && !isLoadingData.value) {
        selectedKecamatanId.value = null;
        selectedKelurahanId.value = null;
        listKelurahan.clear();
      }
      final response = await supabase
          .from('kecamatan')
          .select('id_kecamatan, nama')
          .eq('id_kabupaten', kabId)
          .order('nama');
      listKecamatan.value = response;
    } catch (e) {}
  }

  // 3. AMBIL KELURAHAN
  Future<void> fetchKelurahan(String kecId) async {
    try {
      if (selectedKelurahanId.value != null && !isLoadingData.value) {
        selectedKelurahanId.value = null;
      }
      final response = await supabase
          .from('kelurahan')
          .select('id_kelurahan, nama')
          .eq('id_kecamatan', kecId)
          .order('nama');
      listKelurahan.value = response;
    } catch (e) {}
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
      Get.snackbar('Peringatan', 'Nama lengkap tidak boleh kosong!', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isSaving.value = true;
      final user = supabase.auth.currentUser;
      if (user == null) throw 'Sesi login tidak ditemukan';

      String? finalAvatarUrl = avatarUrl.value;

      // ✅ LOGIKA UPLOAD FOTO KE BUCKET profile-photos & FOLDER pelapor/
      if (selectedImageBytes.value != null && selectedImageExt != null) {
        final fileName = 'pelapor/${user.id}/profile_${DateTime.now().millisecondsSinceEpoch}.$selectedImageExt';

        await supabase.storage.from('profile-photos').uploadBinary(
          fileName,
          selectedImageBytes.value!,
          fileOptions: const FileOptions(upsert: true),
        );
        finalAvatarUrl = supabase.storage.from('profile-photos').getPublicUrl(fileName);
      }

      // ✅ Update data khusus di tabel masyarakat
      final updateDataMasyarakat = {
        'nik': nikC.text.trim(),
        'alamat': alamatDetailC.text.trim(),
        'id_kabupaten': selectedKabupatenId.value,
        'id_kecamatan': selectedKecamatanId.value,
        'id_kelurahan': selectedKelurahanId.value,
      };
      await supabase.from('masyarakat').update(updateDataMasyarakat).eq('id', user.id);

      // ✅ Update data khusus di tabel profiles
      final updateDataProfiles = {
        'full_name': namaC.text.trim(),
        'nomor_telepon': noHpC.text.trim(),
        'foto_profile': finalAvatarUrl,
      };
      await supabase.from('profiles').update(updateDataProfiles).eq('id', user.id);

      refreshProfileData();
      Get.back();
      Get.snackbar('Sukses', 'Profil berhasil diperbarui!', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan profil: $e', backgroundColor: const Color(0xFFE53E3E), colorText: Colors.white);
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