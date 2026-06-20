import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/data/services/api_service.dart';

enum StatusPengaduan { semua, dalamProses, selesai }

class PengaduanItem {
  final String judul;
  final String kategoriMasalah;
  final String tanggal;
  final String idTiket;
  final String status;

  PengaduanItem({
    required this.judul,
    required this.kategoriMasalah,
    required this.tanggal,
    required this.idTiket,
    required this.status,
  });

  factory PengaduanItem.fromJson(Map<String, dynamic> json) {
    String formattedDate = '';
    // Laravel uses created_at instead of tgl_lapor
    final rawDate = json['created_at'] ?? json['tgl_lapor'];
    if (rawDate != null) {
      DateTime dt = DateTime.parse(rawDate).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(dt);
    }

    return PengaduanItem(
      judul: json['judul_pengaduan'] ?? json['jenis_masalah'] ?? 'Tanpa Judul',
      kategoriMasalah: json['jenis_masalah'] ?? 'Lain-lain',
      tanggal: formattedDate,
      idTiket: json['id_pengaduan'] != null ? json['id_pengaduan'].toString() : '-',
      status: json['status'] ?? 'Pending',
    );
  }
}

class RiwayatPengaduanController extends GetxController {
  final ApiService _apiService = ApiService();

  final selectedTab = StatusPengaduan.semua.obs;
  final searchQuery = ''.obs;

  var isLoading = true.obs;
  var allItems = <PengaduanItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRiwayatPengaduan();
  }

  Future<void> fetchRiwayatPengaduan() async {
    try {
      isLoading.value = true;

      final response = await _apiService.dio.get('/pengaduan');

      if (response.data['status'] == true) {
        final List<dynamic> data = response.data['data'];
        allItems.value = data.map((e) => e is Map<String, dynamic> ? PengaduanItem.fromJson(e) : PengaduanItem.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<PengaduanItem> get filteredItems {
    List<PengaduanItem> items = allItems;

    // Filter by tab
    if (selectedTab.value == StatusPengaduan.dalamProses) {
      // ✅ AMAN: Kita paksa jadi huruf kecil semua saat ngecek
      items = items.where((e) =>
      e.status.toLowerCase() == 'menunggu' ||
          e.status.toLowerCase() == 'pending' ||
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