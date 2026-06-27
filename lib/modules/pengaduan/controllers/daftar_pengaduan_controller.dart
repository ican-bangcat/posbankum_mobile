import 'package:get/get.dart';
import '../models/pengaduan_models.dart';
import '../repositories/pengaduan_repository.dart';

enum StatusPengaduan { semua, dalamProses, selesai }

class DaftarPengaduanController extends GetxController {
  final PengaduanRepository _repository;

  DaftarPengaduanController({PengaduanRepository? repository})
      : _repository = repository ?? PengaduanRepository();

  var isLoading = true.obs;
  var selectedTab = StatusPengaduan.semua.obs;
  var searchQuery = ''.obs;
  var isCompactView = false.obs;

  var allItems = <PengaduanItem>[].obs;
  var filteredItems = <PengaduanItem>[].obs;
  var groupedItems = <ListElement>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDaftarPengaduan();

    ever(selectedTab, (_) => applyFilterAndSearch());
    ever(searchQuery, (_) => applyFilterAndSearch());
  }

  Future<void> fetchDaftarPengaduan({bool silent = false}) async {
    try {
      if (!silent) {
        isLoading.value = true;
      }
      final rawList = await _repository.fetchDaftarPengaduan();
      allItems.value = rawList;
      applyFilterAndSearch();
    } catch (e) {
      print("❌ Error fetch daftar pengaduan: $e");
      Get.snackbar('Error', 'Gagal memuat daftar pengaduan');
    } finally {
      if (!silent) {
        isLoading.value = false;
      }
    }
  }

  void changeTab(StatusPengaduan tab) {
    selectedTab.value = tab;
  }

  void applyFilterAndSearch() {
    List<PengaduanItem> result = allItems;

    if (selectedTab.value == StatusPengaduan.dalamProses) {
      result = result.where((item) =>
          item.status.toLowerCase() == 'proses' ||
          item.status.toLowerCase() == 'diproses').toList();
    } else if (selectedTab.value == StatusPengaduan.selesai) {
      result = result.where((item) =>
          item.status.toLowerCase() == 'selesai').toList();
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      result = result.where((item) =>
          item.judul.toLowerCase().contains(query) ||
          item.idTiket.toLowerCase().contains(query)).toList();
    }

    result.sort((a, b) {
      bool aBatal = a.status.toLowerCase() == 'dibatalkan';
      bool bBatal = b.status.toLowerCase() == 'dibatalkan';

      if (aBatal && !bBatal) return 1;
      if (!aBatal && bBatal) return -1;
      return 0;
    });

    filteredItems.value = result;

    final List<ListElement> elements = [];
    if (selectedTab.value == StatusPengaduan.semua) {
      final waiting = result.where((item) =>
          item.status.toLowerCase() == 'menunggu' ||
          item.status.toLowerCase() == 'pending').toList();
      final processing = result.where((item) =>
          item.status.toLowerCase() == 'proses' ||
          item.status.toLowerCase() == 'diproses').toList();
      final finished = result.where((item) =>
          item.status.toLowerCase() == 'selesai').toList();
      final cancelled = result.where((item) =>
          item.status.toLowerCase() == 'dibatalkan' ||
          item.status.toLowerCase() == 'ditolak').toList();

      if (waiting.isNotEmpty) {
        elements.add(HeaderElement('Menunggu Tindak Lanjut', waiting.length));
        elements.addAll(waiting.map((e) => CardElement(e)));
      }
      if (processing.isNotEmpty) {
        elements.add(HeaderElement('Sedang Diproses', processing.length));
        elements.addAll(processing.map((e) => CardElement(e)));
      }
      if (finished.isNotEmpty) {
        elements.add(HeaderElement('Selesai', finished.length));
        elements.addAll(finished.map((e) => CardElement(e)));
      }
      if (cancelled.isNotEmpty) {
        elements.add(HeaderElement('Dibatalkan / Ditolak', cancelled.length));
        elements.addAll(cancelled.map((e) => CardElement(e)));
      }
    } else {
      elements.addAll(result.map((e) => CardElement(e)));
    }

    groupedItems.value = elements;
  }
}