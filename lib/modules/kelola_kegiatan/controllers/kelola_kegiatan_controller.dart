import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KegiatanItem {
  final String id;
  final String judul;
  final String tanggal;
  final String lokasi;
  final String? imageUrl;
  final String status;
  final int jumlahAnggota; // ✅ Tambahan hitung anggota otomatis

  KegiatanItem({
    required this.id,
    required this.judul,
    required this.tanggal,
    required this.lokasi,
    this.imageUrl,
    required this.status,
    required this.jumlahAnggota,
  });

  factory KegiatanItem.fromJson(Map<String, dynamic> json) {
    String formattedDate = '-';

    if (json['tgl_mulai'] != null) {
      final dt = DateTime.parse(json['tgl_mulai']).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(dt);
    }

    String? finalImageUrl = json['thumbnail_path'];
    if (finalImageUrl != null && finalImageUrl.isNotEmpty && !finalImageUrl.startsWith('http')) {
      finalImageUrl = Supabase.instance.client.storage
          .from('kegiatan-thumbnails')
          .getPublicUrl(finalImageUrl);
    }

    // ✅ Hitung jumlah orang yang ada di dalam array JSONB
    int hitungAnggota = 0;
    if (json['anggota_terlibat'] != null && json['anggota_terlibat'] is List) {
      hitungAnggota = (json['anggota_terlibat'] as List).length;
    }

    return KegiatanItem(
      id: json['id_kegiatan'].toString(),
      judul: json['judul'] ?? '',
      tanggal: formattedDate,
      lokasi: json['lokasi'] ?? '',
      imageUrl: finalImageUrl,
      status: json['status'] ?? 'draft',
      jumlahAnggota: hitungAnggota,
    );
  }
}

class KelolaKegiatanController extends GetxController {
  final supabase = Supabase.instance.client;
  var searchQuery = ''.obs;
  var isLoading = true.obs;

  // ✅ Variabel Filter Tanggal
  var selectedFilterDate = Rxn<DateTime>();

  var allKegiatan = <KegiatanItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchKegiatan();
  }

  Future<void> fetchKegiatan() async {
    try {
      isLoading.value = true;
      final user = supabase.auth.currentUser;
      if (user == null) {
        Get.snackbar('Sesi Berakhir', 'Silakan login kembali');
        return;
      }

      final dataPosbankum = await supabase
          .from('posbankum')
          .select('id_posbankum')
          .eq('email_akun', user.email ?? '')
          .maybeSingle();

      if (dataPosbankum == null) return;

      final String idPosbankumAsli = dataPosbankum['id_posbankum'];

      final response = await supabase
          .from('kegiatan')
          .select()
          .eq('id_posbankum', idPosbankumAsli)
          .order('tgl_upload', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      allKegiatan.value = data.map((e) => KegiatanItem.fromJson(e)).toList();

    } catch (e) {
      print("Error Fetch Kegiatan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ LOGIKA FILTER BARU YANG ANTI ERROR
  List<KegiatanItem> get filteredKegiatan {
    List<KegiatanItem> items = allKegiatan.toList(); // Wajib toList()

    // 1. Filter Pencarian Judul
    if (searchQuery.value.isNotEmpty) {
      items = items.where((e) => e.judul.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }

    // 2. Filter Berdasarkan Bulan & Tahun
    if (selectedFilterDate.value != null) {
      // Ubah target jadi misal "Mei 2026"
      final targetMonthYear = DateFormat('MMM yyyy').format(selectedFilterDate.value!);
      items = items.where((e) => e.tanggal.contains(targetMonthYear)).toList();
    }

    return items;
  }

  // ✅ Fungsi memanggil kalender dari UI
  Future<void> pickFilterDate(BuildContext context) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedFilterDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      helpText: 'Pilih Bulan & Tahun',
    );
    if (date != null) {
      selectedFilterDate.value = date;
    }
  }

  void clearFilterDate() {
    selectedFilterDate.value = null;
  }
}