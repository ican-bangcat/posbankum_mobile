import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import '../repositories/pengaduan_repository.dart';

class FormPengaduanController extends GetxController {
  final PengaduanRepository _repository;
  var isLoading = false.obs;

  FormPengaduanController({PengaduanRepository? repository})
      : _repository = repository ?? PengaduanRepository();

  var progressCount = 0.obs;

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

  var selectedFiles = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
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

  String formatTanggalIndo(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF464E97), // primaryBlue
              onPrimary: Colors.white,
              onSurface: Color(0xFF2A2E5E), // darkBlueColor
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF464E97),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      tglKejadianC.text = formatTanggalIndo(picked);
      calculateProgress();
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF464E97), // primaryBlue
              onPrimary: Colors.white,
              onSurface: Color(0xFF2A2E5E), // darkBlueColor
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF464E97),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedTime = picked;
      waktuKejadianC.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      calculateProgress();
    }
  }

  Future<void> submitPengaduan() async {
    String nikBersih = nikC.text.trim();
    if (nikBersih.length != 16) {
      Get.snackbar(
        "Validasi NIK Gagal",
        "NIK wajib 16 digit angka! Saat ini ketikan terbaca: ${nikBersih.length} karakter.",
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (progressCount.value < 9) {
      Get.snackbar("Error", "Mohon lengkapi semua data wajib (${progressCount.value}/9 Lengkap)", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      final userData = await _repository.fetchProfile();
      String namaOtomatis = userData['nama_lengkap'] ?? 'Tanpa Nama';

      if (userData['role'] != 'warga' || userData['masyarakat'] == null) {
        throw 'Data kependudukan Anda tidak ditemukan. Harap hubungi admin.';
      }

      final msk = userData['masyarakat'];
      if (msk['id_kelurahan'] == null) {
        throw 'Data kelurahan Anda tidak ditemukan. Silakan lengkapi profil terlebih dahulu.';
      }

      String prioritasOtomatis = _determinePriority(selectedKategori!);
      String customId = _generatePengaduanId();
      String gabunganKronologi = 'Nama Lurah: ${namaLurahC.text.trim()}\n\nKronologi:\n${kronologiC.text.trim()}';

      final responseData = await _repository.submitPengaduan({
        'nomor_pengaduan': customId,
        'nama_pelapor': namaOtomatis,
        'nik': nikBersih,
        'nomor_telepon': noHpC.text.trim(),
        'judul_pengaduan': judulLaporanC.text.trim(),
        'jenis_masalah': selectedKategori,
        'kronologi': gabunganKronologi,
        'lokasi_kejadian': lokasiC.text.trim(),
        'tanggal_kejadian': selectedDate != null
            ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
            : '',
        'waktu_kejadian': waktuKejadianC.text,
        'prioritas': prioritasOtomatis,
      });

      String generatedUuid = responseData['id_pengaduan'].toString();

      if (selectedFiles.isNotEmpty) {
        await _uploadAndInsertLampiran(generatedUuid);
      }

      Get.offNamed(
        '/pengaduan-success',
        arguments: {
          'pengaduanId': customId,
          'uuidDb': generatedUuid,
        },
      );
    } catch (e) {
      print("❌ Error Submit: $e");
      Get.snackbar(
        "GAGAL - BACA ERROR INI!",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 10),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _uploadAndInsertLampiran(String idPengaduan) async {
    for (var file in selectedFiles) {
      try {
        final fileExt = file.path.split('.').last.toLowerCase();
        final fileName = 'bukti_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}.$fileExt';

        final success = await _repository.uploadLampiran(idPengaduan, file, fileName);
        if (!success) {
          print("❌ Gagal upload file: $fileName");
        }
      } catch (e) {
        print("❌ Gagal upload file: $e");
      }
    }
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
