import 'package:get/get.dart';
import '../models/pengaduan_models.dart';
import '../repositories/pengaduan_repository.dart';

enum StatusPengaduan { semua, dalamProses, selesai }

class RiwayatPengaduanController extends GetxController {
  final PengaduanRepository _repository;

  RiwayatPengaduanController({PengaduanRepository? repository})
      : _repository = repository ?? PengaduanRepository();

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
      final rawList = await _repository.fetchDaftarPengaduan();
      allItems.value = rawList;
    } catch (e) {
      print("Error fetch riwayat pengaduan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<PengaduanItem> get filteredItems {
    List<PengaduanItem> items = allItems;

    if (selectedTab.value == StatusPengaduan.dalamProses) {
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