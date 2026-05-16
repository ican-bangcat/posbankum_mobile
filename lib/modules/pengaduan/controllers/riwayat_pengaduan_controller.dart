import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

enum StatusPengaduan { semua, dalamProses, selesai }

class PengaduanItem {
  final String judul;
  final String tanggal;
  final String idTiket;
  final String status;

  PengaduanItem({
    required this.judul,
    required this.tanggal,
    required this.idTiket,
    required this.status,
  });

  factory PengaduanItem.fromJson(Map<String, dynamic> json) {
    String formattedDate = '';
    if (json['tgl_lapor'] != null) {
      DateTime dt = DateTime.parse(json['tgl_lapor']).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(dt);
    }

    return PengaduanItem(
      judul: json['kategori_masalah'] ?? 'Tanpa Judul',
      tanggal: formattedDate,
      idTiket: json['id'] ?? '-',
      status: json['status'] ?? 'Pending',
    );
  }
}

class RiwayatPengaduanController extends GetxController {
  final supabase = Supabase.instance.client;

  final selectedTab = StatusPengaduan.semua.obs;
  final searchQuery = ''.obs;

  // ✅ INI DIA YANG BIKIN ERROR KALAU GAK ADA
  var isLoading = true.obs;

  var allItems = <PengaduanItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRiwayatPengaduan();
  }

  Future<void> fetchRiwayatPengaduan() async {
    try {
      isLoading.value = true; // Set loading nyala

      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('pengaduan')
          .select()
          .eq('masyarakat_id', user.id)
          .order('tgl_lapor', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      allItems.value = data.map((e) => PengaduanItem.fromJson(e)).toList();

    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading.value = false; // Set loading mati
    }
  }

  List<PengaduanItem> get filteredItems {
    List<PengaduanItem> items = allItems;

    // Filter by tab
    if (selectedTab.value == StatusPengaduan.dalamProses) {
      // ✅ AMAN: Kita paksa jadi huruf kecil semua saat ngecek
      items = items.where((e) =>
      e.status.toLowerCase() == 'proses' ||
          e.status.toLowerCase() == 'diproses').toList();
    } else if (selectedTab.value == StatusPengaduan.selesai) {
      items = items.where((e) => e.status.toLowerCase() == 'selesai').toList();
    }

    if (searchQuery.value.isNotEmpty) {
      items = items
          .where((e) =>
      e.judul.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          e.idTiket.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    return items;
  }

  void changeTab(StatusPengaduan tab) {
    selectedTab.value = tab;
  }
}