import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../views/pengaduan_success_screen.dart'; // Pastikan import ini benar

class PengaduanController extends GetxController {
  // 1. Inisialisasi Supabase & State
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;

  // Input Controllers (Text)
  final kronologiC = TextEditingController();
  final lokasiC = TextEditingController();
// ✅ TAMBAHAN: Variable Tanggal Kejadian
  final tglKejadianC = TextEditingController(); // Buat nampilin teks di form
  DateTime? selectedDate;                       // Buat simpan data tanggal aslinya
  // Variable buat nyimpen Pilihan User
  String? selectedKategori;

  // Variable buat File Upload
  var selectedFileName = ''.obs; // Buat nampilin nama file di UI
  File? selectedFile;            // File aslinya buat diupload

  @override
  void onClose() {
    kronologiC.dispose();
    lokasiC.dispose();
    tglKejadianC.dispose();
    super.onClose();
  }

  // --- 2. FUNGSI PILIH FILE (PICK FILE) ---
  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'], // Hanya boleh gambar & PDF
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        // Cek Ukuran File (Maksimal 5MB)
        if (file.size > 5 * 1024 * 1024) {
          Get.snackbar("Gagal", "Ukuran file maksimal 5 MB",
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }

        // Simpan ke variable
        selectedFile = File(file.path!);
        selectedFileName.value = file.name;

        update(); // Refresh UI kalau perlu
      }
    } catch (e) {
      print("Error Pick File: $e");
      Get.snackbar("Error", "Gagal mengambil file", backgroundColor: Colors.red);
    }
  }

  // Hapus File yang dipilih
  void removeFile() {
    selectedFile = null;
    selectedFileName.value = '';
    update();
  }
// ✅ TAMBAHAN: Fungsi Pilih Tanggal
  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // Gaboleh pilih tanggal masa depan
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      // Format tanggal biar enak dibaca (YYYY-MM-DD)
      tglKejadianC.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      update(); // Refresh UI
    }
  }
  // --- 3. LOGIKA UTAMA: SUBMIT PENGADUAN ---
  Future<void> submitPengaduan() async {
    // A. Validasi Input Dasar
    if (selectedKategori == null || kronologiC.text.isEmpty || lokasiC.text.isEmpty) {
      Get.snackbar("Error", "Mohon lengkapi semua data wajib",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // Ambil User ID yang sedang login
      final user = supabase.auth.currentUser;
      if (user == null) {
        Get.snackbar("Error", "Sesi habis, silakan login ulang");
        return;
      }

      // B. Upload File ke Storage (Kalau ada file)
      String? lampiranUrl;
      if (selectedFile != null) {
        lampiranUrl = await _uploadFileToStorage(user.id);
      }

      // C. Tentukan Prioritas Otomatis
      String prioritasOtomatis = _determinePriority(selectedKategori!);

      // D. Generate ID Unik (Format: PGN-2026-12345)
      String customId = _generatePengaduanId();

      // E. Insert ke Database Supabase
      await supabase.from('pengaduan').insert({
        'id': customId,
        'masyarakat_id': user.id,
        'kategori_masalah': selectedKategori,
        'kronologi': kronologiC.text,
        'lokasi_kejadian': lokasiC.text,
        'prioritas': prioritasOtomatis, // <--- Logika Otomatis Masuk Sini
        'lampiran_url': lampiranUrl,    // URL file (bisa null)
        'tgl_kejadian': tglKejadianC.text,
        'status': 'Pending',
        'tgl_lapor': DateTime.now().toIso8601String(),
      });

      // F. Sukses! Pindah ke Halaman Success
      Get.off(() => PengaduanSuccessScreen(pengaduanId: customId));

    } catch (e) {
      print("Error Submit: $e");
      Get.snackbar("Gagal", "Terjadi kesalahan saat mengirim pengaduan. Coba lagi.",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // --- HELPER 1: UPLOAD FILE ---
  Future<String> _uploadFileToStorage(String userId) async {
    try {
      final fileExt = selectedFile!.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$userId/$fileName'; // Disimpan di folder user biar rapi

      // Upload ke Bucket 'pengaduan-files'
      await supabase.storage.from('pengaduan-files').upload(
        filePath,
        selectedFile!,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      // Ambil Public URL
      final String publicUrl = supabase
          .storage
          .from('pengaduan-files')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw 'Gagal upload file: $e';
    }
  }

  // --- HELPER 2: GENERATE ID (PGN-YYYY-XXXXX) ---
  String _generatePengaduanId() {
    final year = DateTime.now().year;
    final random = Random().nextInt(90000) + 10000; // Random 5 digit (10000-99999)
    return 'PGN-$year-$random';
  }

  // --- HELPER 3: LOGIKA PRIORITAS (OTAKNYA DISINI) 🧠 ---
  String _determinePriority(String kategori) {
    switch (kategori) {
    // PRIORITAS 1 – SANGAT TINGGI
      case 'Kekerasan & Pelanggaran Fisik':
      case 'Kejahatan Seksual':
      case 'Narkotika & Psikotropika':
        return 'Sangat Tinggi';

    // PRIORITAS 2 – TINGGI
      case 'Kekerasan Berbasis Gender (KBG)':
      case 'Perundungan (Bullying) & Kekerasan Non-fisik':
      case 'Kekerasan Siber / Kejahatan Digital':
        return 'Tinggi';

    // PRIORITAS 3 - MENENGAH
      case 'Konflik Keluarga & Perdata Rumah Tangga':
      case 'Kasus Perburuhan / Ketenagakerjaan':
      case 'Sengketa Tanah & Lingkungan':
        return 'Menengah';

    // PRIORITAS 4 – NORMAL
      case 'Tindak Pidana Properti / Harta Benda':
      case 'Sengketa Perdata Umum':
        return 'Normal';

    // PRIORITAS 5 – RENDAH
      case 'Administrasi Pemerintahan / Layanan Publik':
      case 'Lain-lain':
      default:
        return 'Rendah';
    }
  }
}