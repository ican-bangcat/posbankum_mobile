import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../app/data/services/supabase_service.dart';
import 'kelola_kegiatan_controller.dart';
import 'detail_kegiatan_controller.dart';

class EditKegiatanController extends GetxController {
  var kegiatanId = '';
  var existingImageUrl = ''.obs;

  final judulCtrl = TextEditingController();
  final lokasiCtrl = TextEditingController();
  final deskripsiCtrl = TextEditingController();
  final jmlPesertaCtrl = TextEditingController(); // ✅ Tambahan

  var selectedDate = Rxn<DateTime>();
  var selectedImage = Rxn<File>();
  var isLoading = false.obs;

  // ✅ VARIABEL BARU UNTUK MULTI-SELECT PARALEGAL
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

      // 1. Ambil ID Posbankum (untuk narik list semua paralegal)
      final user = WebSupabaseService.client.auth.currentUser;
      if (user != null) {
        final dataPosbankum = await WebSupabaseService.client
            .from('posbankum')
            .select('id_posbankum')
            .eq('email_akun', user.email ?? '')
            .maybeSingle();

        if (dataPosbankum != null) {
          idPosbankumAsli.value = dataPosbankum['id_posbankum'];
          final dataParalegal = await WebSupabaseService.client
              .from('paralegal_members')
              .select('nama_paralegal')
              .eq('id_posbankum', idPosbankumAsli.value)
              .order('is_primary', ascending: false);
          if (dataParalegal != null) {
            paralegalList.value = List<String>.from(dataParalegal.map((e) => e['nama_paralegal']));
          }
        }
      }

      // 2. Ambil data Edit Kegiatan
      final data = await WebSupabaseService.client
          .from('kegiatan')
          .select()
          .eq('id_kegiatan', kegiatanId)
          .single();

      judulCtrl.text = data['judul'] ?? '';
      lokasiCtrl.text = data['lokasi'] ?? '';
      deskripsiCtrl.text = data['deskripsi'] ?? '';
      jmlPesertaCtrl.text = (data['jumlah_peserta'] ?? '').toString();
      existingImageUrl.value = data['thumbnail_path'] ?? '';

      if (data['tgl_mulai'] != null) {
        selectedDate.value = DateTime.parse(data['tgl_mulai']).toLocal();
      }

      // ✅ 3. Terjemahkan JSONB (anggota_terlibat) kembali menjadi List Flutter
      if (data['anggota_terlibat'] != null) {
        List<dynamic> rawAnggota = data['anggota_terlibat'];
        selectedParalegals.value = rawAnggota.map((e) => e.toString()).toList();
      }

    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data awal: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Fungsi Toggle Paralegal
  void toggleParalegal(String nama) {
    if (selectedParalegals.contains(nama)) {
      selectedParalegals.remove(nama);
    } else {
      selectedParalegals.add(nama);
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
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
      String? finalImageUrl = existingImageUrl.value;

      if (selectedImage.value != null) {
        final fileName = 'kegiatan_${DateTime.now().millisecondsSinceEpoch}.png';
        await WebSupabaseService.client.storage.from('kegiatan-thumbnails').upload(fileName, selectedImage.value!);
        finalImageUrl = WebSupabaseService.client.storage.from('kegiatan-thumbnails').getPublicUrl(fileName);
      }

      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value!);

      await WebSupabaseService.client.from('kegiatan').update({
        'judul': judulCtrl.text,
        'tgl_mulai': formattedDate,
        'lokasi': lokasiCtrl.text,
        'deskripsi': deskripsiCtrl.text,
        'jumlah_peserta': jmlPesertaCtrl.text.isNotEmpty ? int.tryParse(jmlPesertaCtrl.text) : null,
        'anggota_terlibat': selectedParalegals, // ✅ Lempar List JSONB-nya lagi
        'thumbnail_path': finalImageUrl,
        'status': 'menunggu',
      }).eq('id_kegiatan', kegiatanId);

      if (Get.isRegistered<KelolaKegiatanController>()) Get.find<KelolaKegiatanController>().fetchKegiatan();
      if (Get.isRegistered<DetailKegiatanController>()) Get.find<DetailKegiatanController>().fetchDetailKegiatan();

      Get.back();
      Get.snackbar("Berhasil", "Kegiatan diperbarui & masuk antrean persetujuan!", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Gagal memperbarui kegiatan: $e");
    } finally {
      isLoading.value = false;
    }
  }
}