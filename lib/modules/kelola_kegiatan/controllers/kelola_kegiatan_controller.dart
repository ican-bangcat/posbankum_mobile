import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class KegiatanItem {
  final String id;
  final String judul;
  final String kategori;
  final String tanggal;
  final String lokasi;
  final String? imageUrl; // Bisa null kalau tidak upload foto

  KegiatanItem({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.tanggal,
    required this.lokasi,
    this.imageUrl,
  });

  // Fungsi untuk convert dari JSON Supabase ke Model Flutter
  factory KegiatanItem.fromJson(Map<String, dynamic> json) {
    String formattedDate = '-';
    if (json['tanggal_mulai'] != null) {
      final dt = DateTime.parse(json['tanggal_mulai']).toLocal();
      formattedDate = DateFormat('dd MMM yyyy • HH:mm').format(dt) + " WIB";
    }

    return KegiatanItem(
      id: json['id'].toString(),
      judul: json['judul'] ?? '',
      kategori: json['kategori'] ?? 'Lainnya',
      tanggal: formattedDate,
      lokasi: json['lokasi'] ?? '',
      imageUrl: json['foto_url'],
    );
  }
}

class KelolaKegiatanController extends GetxController {
  final supabase = Supabase.instance.client;

  var selectedTab = 'Semua'.obs;
  var searchQuery = ''.obs;
  var isLoading = true.obs;

  // List asli dari database
  var allKegiatan = <KegiatanItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchKegiatan(); // Panggil data asli saat start
  }

  Future<void> fetchKegiatan() async {
    try {
      isLoading.value = true;

      // Ambil data dari tabel 'kegiatan' diurutkan dari yang terbaru
      final response = await supabase
          .from('kegiatan')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      allKegiatan.value = data.map((e) => KegiatanItem.fromJson(e)).toList();
    } catch (e) {
      print("Error Fetch Kegiatan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<KegiatanItem> get filteredKegiatan {
    List<KegiatanItem> items = allKegiatan;

    if (selectedTab.value != 'Semua') {
      items = items.where((e) => e.kategori == selectedTab.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      items = items.where((e) =>
          e.judul.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }

    return items;
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
  }
}