import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:open_filex/open_filex.dart';
import '../views/pengaduan_success_screen.dart';

class PengaduanController extends GetxController {
  final supabase = Supabase.instance.client;
  var isLoading = false.obs;

  // ✅ VARIABLE PROGRESS BAR (Otomatis mantau 9 field wajib)
  var progressCount = 0.obs;

  // Input Controllers (Text)
  final judulLaporanC = TextEditingController();
  final namaLurahC = TextEditingController();
  final kronologiC = TextEditingController();
  final lokasiC = TextEditingController();
  final nikC = TextEditingController();
  final noHpC = TextEditingController();
  final tglKejadianC = TextEditingController();
  final waktuKejadianC = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedKategori;

  // Variable Array File
  var selectedFiles = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Pasang "Telinga" di setiap text field, kalau diketik progress nambah!
    nikC.addListener(calculateProgress);
    namaLurahC.addListener(calculateProgress);
    noHpC.addListener(calculateProgress);
    tglKejadianC.addListener(calculateProgress);
    waktuKejadianC.addListener(calculateProgress);
    judulLaporanC.addListener(calculateProgress);
    kronologiC.addListener(calculateProgress);
    lokasiC.addListener(calculateProgress);
  }

  @override
  void onClose() {
    judulLaporanC.dispose();
    namaLurahC.dispose();
    kronologiC.dispose();
    lokasiC.dispose();
    nikC.dispose();
    noHpC.dispose();
    tglKejadianC.dispose();
    waktuKejadianC.dispose();
    super.onClose();
  }

  // ✅ FUNGSI PENGHITUNG PROGRESS
  void calculateProgress() {
    int count = 0;
    if (nikC.text.trim().isNotEmpty) count++;
    if (namaLurahC.text.trim().isNotEmpty) count++;
    if (noHpC.text.trim().isNotEmpty) count++;
    if (tglKejadianC.text.trim().isNotEmpty) count++;
    if (waktuKejadianC.text.trim().isNotEmpty) count++;
    if (judulLaporanC.text.trim().isNotEmpty) count++;
    if (kronologiC.text.trim().isNotEmpty) count++;
    if (lokasiC.text.trim().isNotEmpty) count++;
    if (selectedKategori != null && selectedKategori!.isNotEmpty) count++;

    progressCount.value = count;
  }
  Future<void> bukaFileLokal(String path) async {
    try {
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        Get.snackbar("Info", "Tidak ada aplikasi di HP untuk membuka file ini.");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal membuka file.");
    }
  }
  // --- FUNGSI PICKER & UPLOAD FILE (TETAP SAMA) ---
  Future<void> pickMultipleFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        for (var file in result.files) {
          if (file.size > 5 * 1024 * 1024) {
            Get.snackbar("Gagal", "File ${file.name} melebihi 5 MB dan dilewati.", backgroundColor: Colors.orange, colorText: Colors.white);
            continue;
          }
          if (file.path != null) selectedFiles.add(File(file.path!));
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil file", backgroundColor: Colors.red);
    }
  }

  void removeFileAt(int index) {
    selectedFiles.removeAt(index);
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      tglKejadianC.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      calculateProgress(); // Update progress manual saat tanggal dipilih
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      selectedTime = picked;
      waktuKejadianC.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      calculateProgress(); // Update progress manual saat waktu dipilih
    }
  }

  // --- LOGIKA SUBMIT SUPABASE (TETAP SAMA) ---
  Future<void> submitPengaduan() async {
    if (progressCount.value < 9) { // Pastikan 9 field wajib terisi
      Get.snackbar("Error", "Mohon lengkapi semua data wajib (${progressCount.value}/9 Lengkap)", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final user = supabase.auth.currentUser;
      if (user == null) {
        Get.snackbar("Error", "Sesi habis, silakan login ulang");
        return;
      }


      final dataPelapor = await supabase
          .from('masyarakat')
          .select('nama')
          .eq('id', user.id)
          .maybeSingle();

      String namaOtomatis = dataPelapor?['nama'] ?? 'Tanpa Nama';
      List<String> listUrlLampiran = [];
      if (selectedFiles.isNotEmpty) {
        listUrlLampiran = await _uploadMultipleFiles(user.id);
      }

      String prioritasOtomatis = _determinePriority(selectedKategori!);
      String customId = _generatePengaduanId();

      await supabase.from('pengaduan').insert({
        'id': customId,
        'masyarakat_id': user.id,
        'nama_pelapor': namaOtomatis,
        'nik_pelapor': nikC.text,
        'no_hp_pelapor': noHpC.text,
        'judul_laporan': judulLaporanC.text,
        'nama_lurah': namaLurahC.text,
        'kategori_masalah': selectedKategori,
        'kronologi': kronologiC.text,
        'lokasi_kejadian': lokasiC.text,
        'waktu_kejadian': waktuKejadianC.text,
        'prioritas': prioritasOtomatis,
        'lampiran_urls': listUrlLampiran.isNotEmpty ? listUrlLampiran : null,
        'tgl_kejadian': tglKejadianC.text,
        'status': 'Pending',
        'tgl_lapor': DateTime.now().toIso8601String(),
      });

      Get.off(() => PengaduanSuccessScreen(pengaduanId: customId));

    } catch (e) {
      print("Error Submit: $e");

      // ✅ JURUS CURANG: Nampilin error aslinya langsung di layar HP!
      Get.snackbar(
        "GAGAL - BACA ERROR INI!", // Judulnya
        e.toString(),              // Nampilin pesan error asli dari Supabase
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 10), // Ditahan 10 detik biar sempat di-screenshot
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<String>> _uploadMultipleFiles(String userId) async {
    List<String> uploadedUrls = [];
    for (var file in selectedFiles) {
      try {
        final fileExt = file.path.split('.').last;
        final fileName = 'bukti_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}.$fileExt';
        final filePath = '$userId/$fileName';
        await supabase.storage.from('pengaduan-files').upload(filePath, file, fileOptions: const FileOptions(cacheControl: '3600', upsert: false));
        uploadedUrls.add(supabase.storage.from('pengaduan-files').getPublicUrl(filePath));
      } catch (e) { print("Gagal upload file: $e"); }
    }
    return uploadedUrls;
  }

  String _generatePengaduanId() { return 'PGN-${DateTime.now().year}-${Random().nextInt(90000) + 10000}'; }

  String _determinePriority(String kategori) {
    switch (kategori) {
      case 'Kekerasan & Pelanggaran Fisik': case 'Kejahatan Seksual': case 'Narkotika & Psikotropika': return 'Sangat Tinggi';
      case 'Kekerasan Berbasis Gender (KBG)': case 'Perundungan (Bullying) & Kekerasan Non-fisik': case 'Kekerasan Siber / Kejahatan Digital': return 'Tinggi';
      case 'Konflik Keluarga & Perdata Rumah Tangga': case 'Kasus Perburuhan / Ketenagakerjaan': case 'Sengketa Tanah & Lingkungan': return 'Menengah';
      case 'Tindak Pidana Properti / Harta Benda': case 'Sengketa Perdata Umum': return 'Normal';
      default: return 'Rendah';
    }
  }
}