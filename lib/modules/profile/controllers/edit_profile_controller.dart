import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/profile_controller.dart'; // Sesuaikan path jika error

class EditProfileController extends GetxController {
  final supabase = Supabase.instance.client;

  // --- CONTROLLER UNTUK TEKS ---
  final namaC = TextEditingController();
  final emailC = TextEditingController();
  final noHpC = TextEditingController();
  final alamatDetailC = TextEditingController();

  // --- VARIABEL REAKTIF UI ---
  var displayNama = 'Memuat...'.obs;
  var avatarUrl = ''.obs;
  var isLoadingData = true.obs;

  // --- VARIABEL UNTUK UPLOAD FOTO ---
  var selectedImageBytes = Rxn<Uint8List>(); // Menyimpan gambar secara lokal sblm diupload
  String? selectedImageExt; // Menyimpan ekstensi file (jpg/png)

  // --- VARIABEL REAKTIF UNTUK DROPDOWN WILAYAH ---
  var listKabupaten = [].obs;
  var listKecamatan = [].obs;
  var listKelurahan = [].obs;

  var selectedKabupatenId = Rxn<int>();
  var selectedKecamatanId = Rxn<int>();
  var selectedKelurahanId = Rxn<int>();

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

        final data = await supabase.from('masyarakat').select('*').eq('id', user.id).maybeSingle();

        if (data != null) {
          namaC.text = data['nama'] ?? '';
          noHpC.text = data['no_hp'] ?? '';
          alamatDetailC.text = data['alamat'] ?? '';
          displayNama.value = data['nama'] ?? 'Pengguna';
          avatarUrl.value = data['avatar_url'] ?? '';

          if (data['kabupaten_id'] != null) {
            selectedKabupatenId.value = data['kabupaten_id'];
            await fetchKecamatan(data['kabupaten_id']);

            if (data['kecamatan_id'] != null) {
              selectedKecamatanId.value = data['kecamatan_id'];
              await fetchKelurahan(data['kecamatan_id']);

              if (data['kelurahan_id'] != null) {
                selectedKelurahanId.value = data['kelurahan_id'];
              }
            }
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data profil saat ini: $e');
    } finally {
      isLoadingData.value = false;
    }
  }

  // 1, 2, 3. AMBIL DATA WILAYAH (Tetap Sama)
  Future<void> fetchKabupaten() async {
    try {
      final response = await supabase.from('kabupaten').select('id, nama').order('nama');
      listKabupaten.value = response;
    } catch (e) {}
  }

  Future<void> fetchKecamatan(int kabId) async {
    try {
      if (selectedKecamatanId.value != null && isLoadingData.value == false) {
        selectedKecamatanId.value = null;
        selectedKelurahanId.value = null;
        listKelurahan.clear();
      }
      final response = await supabase.from('kecamatan').select('id, nama').eq('kabupaten_id', kabId).order('nama');
      listKecamatan.value = response;
    } catch (e) {}
  }

  Future<void> fetchKelurahan(int kecId) async {
    try {
      if (selectedKelurahanId.value != null && isLoadingData.value == false) {
        selectedKelurahanId.value = null;
      }
      final response = await supabase.from('kelurahan').select('id, nama').eq('kecamatan_id', kecId).order('nama');
      listKelurahan.value = response;
    } catch (e) {}
  }

  // --- 4. FUNGSI PILIH FOTO DARI GALERI ---
  Future<void> pickFoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Kompres sedikit biar cepat prosesnya
      );

      if (image != null) {
        // Simpan dalam bentuk bytes agar support di Flutter Web & Mobile
        selectedImageBytes.value = await image.readAsBytes();
        selectedImageExt = image.name.split('.').last;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih foto: $e');
    }
  }

  // --- 5. FUNGSI SIMPAN PROFIL & UPLOAD FOTO KE SUPABASE ---
  Future<void> simpanProfil() async {
    if (namaC.text.trim().isEmpty) {
      Get.snackbar('Peringatan', 'Nama lengkap tidak boleh kosong!', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isSaving.value = true;

      final user = supabase.auth.currentUser;
      if (user == null) throw 'Sesi login tidak ditemukan';

      String? finalAvatarUrl = avatarUrl.value; // Pakai URL lama sebagai default

      // JIKA USER MEMILIH FOTO BARU, UPLOAD KE STORAGE DULU!
      if (selectedImageBytes.value != null && selectedImageExt != null) {
        // Buat nama file unik: ID_USER/profile_WAKTU.ekstensi
        final fileName = '${user.id}/profile_${DateTime.now().millisecondsSinceEpoch}.$selectedImageExt';

        // Upload ke bucket 'avatars'
        await supabase.storage.from('avatars').uploadBinary(
          fileName,
          selectedImageBytes.value!,
          fileOptions: const FileOptions(upsert: true), // Timpa jika nama file sama
        );

        // Ambil URL publik dari gambar yang barusan diupload
        finalAvatarUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
      }

      // Siapkan data untuk tabel masyarakat
      final updateData = {
        'nama': namaC.text.trim(),
        'no_hp': noHpC.text.trim(),
        'alamat': alamatDetailC.text.trim(),
        'kabupaten_id': selectedKabupatenId.value,
        'kecamatan_id': selectedKecamatanId.value,
        'kelurahan_id': selectedKelurahanId.value,
      };

      // Kalau ada avatarUrl (baru maupun lama), masukkan ke data update
      if (finalAvatarUrl.isNotEmpty) {
        updateData['avatar_url'] = finalAvatarUrl;
      }

      // Tembak datanya ke tabel masyarakat
      await supabase.from('masyarakat').update(updateData).eq('id', user.id);

      // Trigger refresh di halaman profile
      refreshProfileData();

      // Kembalikan user ke halaman profile
      Get.back();

      // Tampilkan notif sukses
      Get.snackbar('Sukses', 'Profil berhasil diperbarui!', backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan profil: $e', backgroundColor: const Color(0xFFE53E3E), colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  // --- 6. FUNGSI HELPER REFRESH ---
  void refreshProfileData() {
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().fetchUserData();
    }
  }
}