import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

enum StatusPengaduan { semua, dalamProses, selesai }

class PengaduanItem {
  final String idDb; // ✅ Tambahkan ini untuk menyimpan UUID aslinya
  final String idTiket;
  final String judul;
  final String tanggal;
  final String kategoriMasalah;
  final String status;

  PengaduanItem({
    required this.idDb,
    required this.idTiket,
    required this.judul,
    required this.tanggal,
    required this.kategoriMasalah,
    required this.status,
  });

  factory PengaduanItem.fromJson(Map<String, dynamic> json) {
    String formattedDate = '-';
    if (json['tgl_lapor'] != null) {
      final dt = DateTime.parse(json['tgl_lapor']).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(dt);
    }
    return PengaduanItem(
      idDb: json['id'].toString(), // ✅ Menyimpan UUID untuk fungsi onTap detail kasus
      idTiket: json['no_tiket']?.toString().toUpperCase() ?? 'TIDAK ADA TIKET', // ✅ Mengambil PGN-xxx untuk UI
      judul: json['judul_laporan'] ?? 'Tanpa Judul',
      tanggal: formattedDate,
      kategoriMasalah: json['kategori_masalah'] ?? 'Lain-lain',
      status: json['status'] ?? 'Pending',
    );
  }
}

class DaftarPengaduanController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = true.obs;
  var selectedTab = StatusPengaduan.semua.obs;
  var searchQuery = ''.obs;

  var allItems = <PengaduanItem>[].obs;
  var filteredItems = <PengaduanItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDaftarPengaduan();

    ever(selectedTab, (_) => applyFilterAndSearch());
    ever(searchQuery, (_) => applyFilterAndSearch());
  }

  Future<void> fetchDaftarPengaduan() async {
    try {
      isLoading.value = true;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final List<dynamic> resultData = await supabase
          .from('pengaduan')
          .select()
          .eq('masyarakat_id', user.id)
          .order('tgl_lapor', ascending: false);

      List<PengaduanItem> rawList = resultData.map((e) => PengaduanItem.fromJson(e)).toList();

      allItems.value = rawList;
      applyFilterAndSearch();

    } catch (e) {
      print("Error fetch daftar: $e");
      Get.snackbar('Error', 'Gagal memuat daftar pengaduan');
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(StatusPengaduan tab) {
    selectedTab.value = tab;
  }

  void applyFilterAndSearch() {
    List<PengaduanItem> result = allItems;

    if (selectedTab.value == StatusPengaduan.dalamProses) {
      result = result.where((item) =>
      item.status.toLowerCase() == 'pending' ||
          item.status.toLowerCase() == 'diproses'
      ).toList();
    } else if (selectedTab.value == StatusPengaduan.selesai) {
      result = result.where((item) =>
      item.status.toLowerCase() == 'selesai'
      ).toList();
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      result = result.where((item) =>
      item.judul.toLowerCase().contains(query) ||
          item.idTiket.toLowerCase().contains(query)
      ).toList();
    }

    result.sort((a, b) {
      bool aBatal = a.status.toLowerCase() == 'dibatalkan';
      bool bBatal = b.status.toLowerCase() == 'dibatalkan';

      if (aBatal && !bBatal) return 1;
      if (!aBatal && bBatal) return -1;
      return 0;
    });

    filteredItems.value = result;
  }
}