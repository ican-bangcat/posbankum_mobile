import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'kelola_kegiatan_controller.dart';
import '../../../app/routes/app_routes.dart';

class TambahKegiatanController extends GetxController {
  final supabase = Supabase.instance.client;

  // Form Controllers
  final judulCtrl = TextEditingController();
  final lokasiCtrl = TextEditingController();
  final deskripsiCtrl = TextEditingController();

  var selectedDate = Rxn<DateTime>();
  var selectedImage = Rxn<File>();
  var isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();

  // Pilih Foto
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  // Pilih Tanggal & Waktu
  Future<void> pickDateTime(BuildContext context) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        selectedDate.value = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      }
    }
  }

  // Simpan Kegiatan
  Future<void> simpanKegiatan() async {
    if (judulCtrl.text.isEmpty || selectedDate.value == null || lokasiCtrl.text.isEmpty) {
      Get.snackbar("Error", "Mohon isi Judul, Tanggal, dan Lokasi!");
      return;
    }

    try {
      isLoading.value = true;
      final userId = supabase.auth.currentUser!.id;
      String? imageUrl;

      // 1. Upload Foto ke Supabase Storage (Jika ada foto)
      if (selectedImage.value != null) {
        final fileName = 'kegiatan_${DateTime.now().millisecondsSinceEpoch}.png';
        final path = 'kegiatan_images/$fileName';

        await supabase.storage.from('kegiatan_assets').upload(path, selectedImage.value!);
        imageUrl = supabase.storage.from('kegiatan_assets').getPublicUrl(path);
      }

      // 2. Insert ke Tabel kegiatan
      await supabase.from('kegiatan').insert({
        'judul': judulCtrl.text,
        'kategori': 'Penyuluhan', // Default dulu, bisa dikembangkan
        'tanggal_mulai': selectedDate.value!.toIso8601String(),
        'lokasi': lokasiCtrl.text,
        'deskripsi': deskripsiCtrl.text,
        'foto_url': imageUrl,
        'paralegal_id': userId,
      });

      // ✅ INI YANG DIUBAH!
      // Refresh list kegiatan biar pas balik data barunya udah muncul
      Get.find<KelolaKegiatanController>().fetchKegiatan();

      // Langsung gas lempar ke halaman Sukses (ombak biru)
      Get.offNamed(AppRoutes.KONFIRMASI_KEGIATAN);

    } catch (e) {
      print("Error simpan: $e");
      Get.snackbar("Error", "Gagal menyimpan kegiatan: $e");
    } finally {
      isLoading.value = false;
    }
  }
}