import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// --- ENUM UNTUK TAB FILTER ---
enum StatusPengaduan { semua, dalamProses, selesai }

// --- MODEL DATA UNTUK LIST ---
class PengaduanItem {
  final String idTiket;
  final String judul;
  final String tanggal;
  final String kategoriMasalah;
  final String status;

  PengaduanItem({
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
      // ✅ HAPUS SUBSTRING-NYA, BIAR ID-NYA UTUH 14 KARAKTER
      idTiket: json['id'].toString().toUpperCase(),
      judul: json['judul_laporan'] ?? 'Tanpa Judul',
      tanggal: formattedDate,
      kategoriMasalah: json['kategori_masalah'] ?? 'Lain-lain',
      status: json['status'] ?? 'Pending',
    );
  }
}

class DaftarPengaduanController extends GetxController {
  final supabase = Supabase.instance.client;

  // Variabel Reactive (Obs)
  var isLoading = true.obs;
  var selectedTab = StatusPengaduan.semua.obs;
  var searchQuery = ''.obs;

  // Nyimpen Data Mentah dari Database
  var allItems = <PengaduanItem>[].obs;

  // Data yang Tampil di Layar (Setelah di-filter & Search)
  var filteredItems = <PengaduanItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDaftarPengaduan();

    // Otomatis jalanin fungsi filter setiap kali Tab diklik atau Search diketik
    ever(selectedTab, (_) => applyFilterAndSearch());
    ever(searchQuery, (_) => applyFilterAndSearch());
  }

  // 1. FUNGSI NARIK DATA DARI SUPABASE
  Future<void> fetchDaftarPengaduan() async {
    try {
      isLoading.value = true;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Tarik data khusus milik user yang lagi login
      final List<dynamic> resultData = await supabase
          .from('pengaduan')
          .select()
          .eq('masyarakat_id', user.id)
          .order('tgl_lapor', ascending: false); // Urutkan dari yang terbaru

      // Konversi ke model list
      List<PengaduanItem> rawList = resultData.map((e) => PengaduanItem.fromJson(e)).toList();

      allItems.value = rawList;
      applyFilterAndSearch(); // Terapkan filter setelah data masuk

    } catch (e) {
      print("Error fetch daftar: $e");
      Get.snackbar('Error', 'Gagal memuat daftar pengaduan');
    } finally {
      isLoading.value = false;
    }
  }

  // 2. FUNGSI GANTI TAB
  void changeTab(StatusPengaduan tab) {
    selectedTab.value = tab;
  }

  // 3. FUNGSI FILTER & SEARCH SEKALIGUS + SORTING "DIBATALKAN"
  void applyFilterAndSearch() {
    List<PengaduanItem> result = allItems;

    // --- FILTER TAB ---
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
    // Kalau Tab "Semua", biarin nampilin semuanya (termasuk yang Dibatalkan)

    // --- SEARCHING ---
    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      result = result.where((item) =>
      item.judul.toLowerCase().contains(query) ||
          item.idTiket.toLowerCase().contains(query)
      ).toList();
    }

    // --- ✅ SORTING: YANG DIBATALKAN SELALU DI BAWAH ---
    result.sort((a, b) {
      bool aBatal = a.status.toLowerCase() == 'dibatalkan';
      bool bBatal = b.status.toLowerCase() == 'dibatalkan';

      if (aBatal && !bBatal) return 1;  // A ditaruh di bawah B
      if (!aBatal && bBatal) return -1; // A ditaruh di atas B
      return 0; // Kalau sama-sama batal atau sama-sama enggak, biarin urutannya (udah urut dari tgl terbaru)
    });

    filteredItems.value = result;
  }
}