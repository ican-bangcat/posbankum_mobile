import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:open_filex/open_filex.dart';

class PengaduanController extends GetxController {
  final supabase = Supabase.instance.client;
  var isLoading = false.obs;

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

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      tglKejadianC.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      calculateProgress();
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      selectedTime = picked;
      waktuKejadianC.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      calculateProgress();
    }
  }

  Future<void> submitPengaduan() async {
    // 🚀 VALIDASI 1: Bersihkan spasi gaib dan pastikan tepat 16 digit!
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

    // 🚀 VALIDASI 2: Cek progress wajib 9/9
    if (progressCount.value < 9) {
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

      // Ambil nama dari tabel profil
      final dataPelapor = await supabase
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();
      String namaOtomatis = dataPelapor?['full_name'] ?? 'Tanpa Nama';

      // 🚀 LOGIKA POSBANKUM: Cari id_kelurahan milik pelapor
      final dataMasyarakat = await supabase.from('masyarakat').select('id_kelurahan').eq('id', user.id).maybeSingle();
      if (dataMasyarakat == null || dataMasyarakat['id_kelurahan'] == null) {
        Get.snackbar("Profil Belum Lengkap", "Data kelurahan Anda tidak ditemukan. Silakan lengkapi profil terlebih dahulu.", backgroundColor: Colors.orange.shade700, colorText: Colors.white);
        return;
      }
      String idKelurahanUser = dataMasyarakat['id_kelurahan'];

      // 🚀 LOGIKA POSBANKUM: Cari id_posbankum yang melayani kelurahan pelapor
      final posbankumTujuan = await supabase.from('posbankum').select('id_posbankum').eq('id_kelurahan', idKelurahanUser).maybeSingle();
      if (posbankumTujuan == null) {
        Get.snackbar("Peringatan", "Tidak ada Posbankum yang melayani kelurahan Anda saat ini.", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      String idPosbankum = posbankumTujuan['id_posbankum'];

      String prioritasOtomatis = _determinePriority(selectedKategori!);
      String customId = _generatePengaduanId();
      String gabunganKronologi = 'Lurah/Kelurahan: ${namaLurahC.text.trim()}\n\nKronologi:\n${kronologiC.text.trim()}';

      // 🔵 TAHAP 1: SIMPAN DATA UTAMA KE TABEL `pengaduan`
      final insertedData = await supabase.from('pengaduan').insert({
        'id_posbankum': idPosbankum, // 🚀 WAJIB DIISI!
        'nomor_pengaduan': customId,
        'masyarakat_id': user.id,
        'created_by': user.id,
        'nama_pelapor': namaOtomatis,
        'nik': nikBersih,
        'nomor_telepon': noHpC.text.trim(),
        'judul_pengaduan': judulLaporanC.text.trim(),
        'jenis_masalah': selectedKategori,
        'kronologi': gabunganKronologi,
        'lokasi_kejadian': lokasiC.text.trim(),
        'tanggal_kejadian': tglKejadianC.text,
        'waktu_kejadian': waktuKejadianC.text,
        'prioritas': prioritasOtomatis,
        'status': 'menunggu', // 🚀 SESUAI ATURAN BARU
      }).select('id_pengaduan').single();

      // Tangkap UUID pengaduan yang baru dibuat
      String generatedUuid = insertedData['id_pengaduan'];

      // 🔵 TAHAP 2: JIKA ADA FILE, UPLOAD & SIMPAN KE TABEL `pengaduan_lampiran`
      if (selectedFiles.isNotEmpty) {
        await _uploadAndInsertLampiran(user.id, generatedUuid);
      }

      // 🔵 TAHAP 3: LEMPAR KE HALAMAN SUKSES
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

  // 🚀 FUNGSI UPLOAD & INSERT KE TABEL LAMPIRAN
  Future<void> _uploadAndInsertLampiran(String userId, String idPengaduan) async {
    List<Map<String, dynamic>> lampiranDataToInsert = [];

    for (var file in selectedFiles) {
      try {
        final fileExt = file.path.split('.').last;
        final fileSize = file.lengthSync();
        final fileName = 'bukti_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}.$fileExt';

        // Format Path: UUID-User/nama-file.jpg
        final filePath = '$userId/$fileName';

        // 1. Upload ke Storage Bucket "pengaduan-lampiran"
        await supabase.storage.from('pengaduan-lampiran').upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false)
        );

        // 2. Dapatkan URL Publik
        final publicUrl = supabase.storage.from('pengaduan-lampiran').getPublicUrl(filePath);

        // 3. Siapkan data untuk dimasukkan ke tabel `pengaduan_lampiran`
        lampiranDataToInsert.add({
          'id_pengaduan': idPengaduan,
          'nama_file': fileName,
          'path_file': publicUrl,
          'mime_type': fileExt,
          'size_bytes': fileSize,
        });
      } catch (e) {
        print("❌ Gagal upload file: $e");
      }
    }

    // 4. Lakukan Insert Massal (Batch Insert) ke Database
    if (lampiranDataToInsert.isNotEmpty) {
      await supabase.from('pengaduan_lampiran').insert(lampiranDataToInsert);
    }
  }

  String _generatePengaduanId() { return 'PGN-${DateTime.now().year}-${Random().nextInt(90000) + 10000}'; }

  // 🚀 PRIORITAS VERSI OWNER
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