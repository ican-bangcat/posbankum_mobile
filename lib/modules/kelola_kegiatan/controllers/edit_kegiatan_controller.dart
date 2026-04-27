import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'kelola_kegiatan_controller.dart';
import 'detail_kegiatan_controller.dart';

class EditKegiatanController extends GetxController {
  final supabase = Supabase.instance.client;

  var kegiatanId = '';
  var existingImageUrl = ''.obs;

  final judulCtrl = TextEditingController();
  final lokasiCtrl = TextEditingController();
  final deskripsiCtrl = TextEditingController();

  var selectedDate = Rxn<DateTime>();
  var selectedTime = Rxn<TimeOfDay>();
  var selectedImage = Rxn<File>();
  var isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Tangkap ID yang dikirim dari halaman detail
    kegiatanId = Get.arguments as String;
    fetchDataAwal();
  }

  Future<void> fetchDataAwal() async {
    try {
      isLoading.value = true;
      final data = await supabase.from('kegiatan').select().eq('id', kegiatanId).single();

      judulCtrl.text = data['judul'] ?? '';
      lokasiCtrl.text = data['lokasi'] ?? '';
      deskripsiCtrl.text = data['deskripsi'] ?? '';
      existingImageUrl.value = data['foto_url'] ?? '';

      if (data['tanggal_mulai'] != null) {
        final dt = DateTime.parse(data['tanggal_mulai']).toLocal();
        selectedDate.value = dt;
        selectedTime.value = TimeOfDay(hour: dt.hour, minute: dt.minute);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data awal');
    } finally {
      isLoading.value = false;
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

  Future<void> pickTime(BuildContext context) async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), // ✅ 24 Jam
          child: child!,
        );
      },
    );
    if (time != null) selectedTime.value = time;
  }

  Future<void> updateKegiatan() async {
    if (judulCtrl.text.isEmpty || selectedDate.value == null || selectedTime.value == null || lokasiCtrl.text.isEmpty) {
      Get.snackbar("Error", "Mohon lengkapi form yang wajib!");
      return;
    }

    try {
      isLoading.value = true;
      String? finalImageUrl = existingImageUrl.value;

      // Kalau user pilih gambar baru, upload ke Storage
      if (selectedImage.value != null) {
        final fileName = 'kegiatan_${DateTime.now().millisecondsSinceEpoch}.png';
        final path = 'kegiatan_images/$fileName';
        await supabase.storage.from('kegiatan_assets').upload(path, selectedImage.value!);
        finalImageUrl = supabase.storage.from('kegiatan_assets').getPublicUrl(path);
      }

      // Gabungkan Tanggal & Jam
      final finalDateTime = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        selectedTime.value!.hour,
        selectedTime.value!.minute,
      );

      // Update ke database
      await supabase.from('kegiatan').update({
        'judul': judulCtrl.text,
        'tanggal_mulai': finalDateTime.toIso8601String(),
        'lokasi': lokasiCtrl.text,
        'deskripsi': deskripsiCtrl.text,
        'foto_url': finalImageUrl,
      }).eq('id', kegiatanId);

      // Refresh data di layar list dan detail
      if (Get.isRegistered<KelolaKegiatanController>()) Get.find<KelolaKegiatanController>().fetchKegiatan();
      if (Get.isRegistered<DetailKegiatanController>()) Get.find<DetailKegiatanController>().fetchDetailKegiatan();

      Get.back(); // Kembali ke halaman Detail
      Get.snackbar("Berhasil", "Kegiatan berhasil diperbarui", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Gagal memperbarui kegiatan: $e");
    } finally {
      isLoading.value = false;
    }
  }
}