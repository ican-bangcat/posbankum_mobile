import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/data/services/api_service.dart';

enum StatusPengaduan { semua, dalamProses, selesai }

class PengaduanItem {
  final String idDb;
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
    // ✅ FIX: Ganti tgl_lapor jadi created_at
    if (json['created_at'] != null) {
      final dt = DateTime.parse(json['created_at']).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(dt);
    }
    return PengaduanItem(
      // ✅ FIX: Sesuaikan nama kolom dengan database Web
      idDb: json['id_pengaduan'].toString(),
      idTiket: json['nomor_pengaduan']?.toString().toUpperCase() ?? 'TIDAK ADA TIKET',
      judul: json['judul_pengaduan'] ?? 'Tanpa Judul',
      tanggal: formattedDate,
      kategoriMasalah: json['jenis_masalah'] ?? 'Lain-lain',
      status: json['status'] ?? 'Pending',
    );
  }
}

class DaftarPengaduanController extends GetxController {
  final ApiService _apiService = ApiService();

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

      final response = await _apiService.dio.get('/pengaduan');

      if (response.data['status'] == true) {
        final List<dynamic> resultData = response.data['data'];
        List<PengaduanItem> rawList = resultData.map((e) => PengaduanItem.fromJson(e)).toList();

        allItems.value = rawList;
        applyFilterAndSearch();
      } else {
        throw response.data['message'] ?? 'Gagal memuat daftar pengaduan';
      }
    } catch (e) {
      print("❌ Error fetch daftar pengaduan: $e");
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
      item.status.toLowerCase() == 'menunggu' ||
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