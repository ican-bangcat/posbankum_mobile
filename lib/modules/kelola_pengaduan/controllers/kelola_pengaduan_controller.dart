import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../app/data/services/api_service.dart';
import '../models/kasus_model.dart';

class KelolaPengaduanController extends GetxController {
  final ApiService _apiService;

  KelolaPengaduanController({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  var selectedTab = 0.obs;
  var searchQuery = ''.obs;
  var isCompactView = false.obs;
  var isLoading = true.obs;
  var allKasus = <KasusItem>[].obs;

  // Filter States
  var sortBy = 'priority'.obs; // 'priority', 'newest', 'oldest'
  var filterPriority = 'Semua'.obs; // 'Semua', 'Sangat Tinggi', 'Tinggi', etc.
  var filterCategory = 'Semua'.obs; // 'Semua', etc.

  // Lazy Loading / Pagination States
  final ScrollController scrollController = ScrollController();
  int page = 1;
  var hasMore = true.obs;
  var isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPengaduan(isRefresh: true);
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (hasMore.value && !isLoadingMore.value && !isLoading.value) {
        loadMorePengaduan();
      }
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void resetFilters() {
    sortBy.value = 'priority';
    filterPriority.value = 'Semua';
    filterCategory.value = 'Semua';
  }

  Future<void> fetchPengaduan({bool isRefresh = true}) async {
    try {
      if (isRefresh) {
        isLoading.value = true;
        page = 1;
        hasMore.value = true;
      }

      final response = await _apiService.dio.get('/pengaduan', queryParameters: {
        'page': page,
        'limit': 10,
      });

      if (response.data['status'] == true) {
        final List<dynamic> data = response.data['data'];
        final List<KasusItem> fetchedData = data
            .map((e) => e is Map<String, dynamic> ? KasusItem.fromJson(e) : KasusItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        if (isRefresh) {
          allKasus.assignAll(fetchedData);
        } else {
          allKasus.addAll(fetchedData);
        }

        if (fetchedData.length < 10) {
          hasMore.value = false;
        }
      } else {
        throw response.data['message'] ?? 'Gagal mengambil data pengaduan';
      }
    } catch (e) {
      debugPrint('Kegagalan sinkronisasi data pengaduan: $e');
      Get.snackbar('Error', 'Gagal memuat data pengaduan: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMorePengaduan() async {
    if (isLoadingMore.value) return;
    isLoadingMore.value = true;
    page++;
    await fetchPengaduan(isRefresh: false);
  }

  // 🚀 FIX: Konversi dari kolom 'prioritas' database ke angka untuk sorting (Level 1 paling Urgent)
  int getPriorityValue(String prioritas) {
    switch(prioritas) {
      case 'Sangat Tinggi': return 1;
      case 'Tinggi': return 2;
      case 'Menengah': return 3;
      case 'Normal': return 4;
      case 'Rendah': return 5;
      default: return 4;
    }
  }

  // Getter reaktif untuk filtrasi dan pencarian
  List<KasusItem> get filteredKasus {
    List<KasusItem> filtered = allKasus.where((kasus) {
      bool matchTab = true;
      if (selectedTab.value == 1) matchTab = (kasus.status == 'proses' || kasus.status == 'diproses');
      if (selectedTab.value == 2) matchTab = (kasus.status == 'selesai');

      bool matchSearch = kasus.judul.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          kasus.kategori.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          kasus.lokasi.toLowerCase().contains(searchQuery.value.toLowerCase());

      bool matchPriority = filterPriority.value == 'Semua' || kasus.prioritas == filterPriority.value;
      bool matchCategory = filterCategory.value == 'Semua' || kasus.kategori == filterCategory.value;

      return matchTab && matchSearch && matchPriority && matchCategory;
    }).toList();

    // Sorting
    if (sortBy.value == 'priority') {
      filtered.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
    } else if (sortBy.value == 'newest') {
      filtered.sort((a, b) => b.tanggalPengajuan.compareTo(a.tanggalPengajuan));
    } else if (sortBy.value == 'oldest') {
      filtered.sort((a, b) => a.tanggalPengajuan.compareTo(b.tanggalPengajuan));
    }

    return filtered;
  }

  // 🚀 GETTER UNTUK PENGELOMPOKAN KASUS (Tab Semua)
  List<ListElement> get groupedListElements {
    final List<ListElement> elements = [];
    final query = searchQuery.value.toLowerCase();

    bool matchesSearch(KasusItem k) {
      return k.judul.toLowerCase().contains(query) ||
          k.kategori.toLowerCase().contains(query) ||
          k.lokasi.toLowerCase().contains(query);
    }

    final searchedKasus = query.isEmpty ? allKasus : allKasus.where(matchesSearch).toList();

    final filtered = searchedKasus.where((k) {
      bool matchPriority = filterPriority.value == 'Semua' || k.prioritas == filterPriority.value;
      bool matchCategory = filterCategory.value == 'Semua' || k.kategori == filterCategory.value;
      return matchPriority && matchCategory;
    }).toList();

    void sortList(List<KasusItem> list) {
      if (sortBy.value == 'priority') {
        list.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
      } else if (sortBy.value == 'newest') {
        list.sort((a, b) => b.tanggalPengajuan.compareTo(a.tanggalPengajuan));
      } else if (sortBy.value == 'oldest') {
        list.sort((a, b) => a.tanggalPengajuan.compareTo(b.tanggalPengajuan));
      }
    }

    final waiting = filtered.where((k) => k.status == 'menunggu').toList();
    sortList(waiting);
    final processing = filtered.where((k) => k.status == 'proses' || k.status == 'dalam proses' || k.status == 'diproses').toList();
    sortList(processing);
    final finished = filtered.where((k) => k.status == 'selesai').toList();
    sortList(finished);
    final cancelled = filtered.where((k) => k.status == 'dibatalkan').toList();
    sortList(cancelled);

    if (waiting.isNotEmpty) {
      elements.add(HeaderElement('Kasus Menunggu', waiting.length));
      elements.addAll(waiting.map((k) => CardElement(k)));
    }

    if (processing.isNotEmpty) {
      elements.add(HeaderElement('Sedang Diproses', processing.length));
      elements.addAll(processing.map((k) => CardElement(k)));
    }

    if (finished.isNotEmpty) {
      elements.add(HeaderElement('Selesai', finished.length));
      elements.addAll(finished.map((k) => CardElement(k)));
    }

    if (cancelled.isNotEmpty) {
      elements.add(HeaderElement('Dibatalkan / Ditolak', cancelled.length));
      elements.addAll(cancelled.map((k) => CardElement(k)));
    }

    return elements;
  }
}
