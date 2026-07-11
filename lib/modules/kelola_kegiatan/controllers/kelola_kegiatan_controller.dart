import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/kegiatan_model.dart';
import '../repositories/kegiatan_repository.dart';

class KelolaKegiatanController extends GetxController {
  final KegiatanRepository _repository;
  var searchQuery = ''.obs;
  var isLoading = true.obs;

  // ✅ Variabel Filter Tanggal
  var selectedFilterDate = Rxn<DateTime>();

  var allKegiatan = <KegiatanItem>[].obs;

  KelolaKegiatanController({KegiatanRepository? repository})
      : _repository = repository ?? KegiatanRepository();

  @override
  void onInit() {
    super.onInit();
    fetchKegiatan();
  }

  Future<void> fetchKegiatan() async {
    try {
      isLoading.value = true;
      final list = await _repository.fetchKegiatan();
      allKegiatan.value = list;
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
      items = items.where((e) =>
        e.judul.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        e.lokasi.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    // 2. Filter Berdasarkan Tanggal Spesifik
    if (selectedFilterDate.value != null) {
      final targetDateStr = DateFormat('dd MMM yyyy').format(selectedFilterDate.value!);
      items = items.where((e) => e.tanggal == targetDateStr).toList();
    }

    // Force reactivity by touching both observables
    searchQuery.value;
    selectedFilterDate.value;

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