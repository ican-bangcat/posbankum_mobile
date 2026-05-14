import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../app/data/services/supabase_service.dart';
import 'kelola_kegiatan_controller.dart';
import '../../../app/routes/app_routes.dart';

class TambahKegiatanController extends GetxController {
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
      final user = WebSupabaseService.client.auth.currentUser;
      if (user == null) return;

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

    if (idPosbankumAsli.value.isEmpty) {
      Get.snackbar("Error", "Gagal memverifikasi identitas Posbankum.");
      return;
    }

    try {
      isLoading.value = true;
      String? imageUrl;

      if (selectedImage.value != null) {
        final fileName = 'kegiatan_${DateTime.now().millisecondsSinceEpoch}.png';
        final path = 'posbankum/${idPosbankumAsli.value}/$fileName';

        await WebSupabaseService.client.storage
            .from('kegiatan-thumbnails')
            .upload(path, selectedImage.value!);

        // ✅ SIMPAN PATH NYA SAJA (Sesuai Standar Web)
        imageUrl = path;
      }

      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value!);

      await WebSupabaseService.client.from('kegiatan').insert({
        'id_posbankum': idPosbankumAsli.value,
        'judul': judulCtrl.text,
        'deskripsi': deskripsiCtrl.text,
        'lokasi': lokasiCtrl.text,
        'status': 'menunggu',
        'tgl_mulai': formattedDate,
        'thumbnail_path': imageUrl,
        'jumlah_peserta': jmlPesertaCtrl.text.isNotEmpty ? int.tryParse(jmlPesertaCtrl.text) : null,
        'anggota_terlibat': selectedParalegals,
      });

      if (Get.isRegistered<KelolaKegiatanController>()) {
        Get.find<KelolaKegiatanController>().fetchKegiatan();
      }

      Get.offNamed(AppRoutes.KONFIRMASI_KEGIATAN);

    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan kegiatan: $e");
    } finally {
      isLoading.value = false;
    }
  }
}