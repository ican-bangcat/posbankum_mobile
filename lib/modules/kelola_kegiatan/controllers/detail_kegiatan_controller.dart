import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import '../models/kegiatan_model.dart';
import '../repositories/kegiatan_repository.dart';

class DetailKegiatanController extends GetxController {
  final KegiatanRepository _repository;
  var isLoading = true.obs;
  var kegiatanData = Rxn<KegiatanItem>();

  // Resolved posbankum info
  var namaPosbankum = ''.obs;
  var kecamatan = ''.obs;
  var kabupaten = ''.obs;
  var namaPelapor = ''.obs;

  DetailKegiatanController({KegiatanRepository? repository})
      : _repository = repository ?? KegiatanRepository();

  @override
  void onInit() {
    super.onInit();
    fetchDetailKegiatan();
  }

  Future<void> fetchDetailKegiatan() async {
    try {
      isLoading.value = true;
      final String? id = Get.arguments;

      if (id == null) {
        Get.snackbar("Error", "ID Kegiatan tidak ditemukan");
        return;
      }

      final item = await _repository.fetchDetailKegiatan(id);
      kegiatanData.value = item;

      // Resolve nama posbankum dari API /posbankum/{id}
      await _resolvePosbankumInfo(item);
    } catch (e) {
      print("Error fetch detail: $e");
      Get.snackbar("Error", "Gagal memuat detail kegiatan");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _resolvePosbankumInfo(KegiatanItem item) async {
    final storage = GetStorage();
    final userData = storage.read('user');

    // Default fallback dari session user yg login
    namaPosbankum.value = userData?['posbankum']?['nama_posbankum'] ?? 'Posbankum';
    namaPelapor.value = userData?['nama_lengkap'] ?? 'Paralegal';

    // Jika item punya id_posbankum, fetch detail posbankum dari API
    if (item.idPosbankum != null && item.idPosbankum!.isNotEmpty) {
      try {
        final posbankumData = await _repository.fetchPosbankum(item.idPosbankum!);
        // Response: { nama, kelurahan, kecamatan, kabupaten, ... }
        namaPosbankum.value = posbankumData['nama'] ?? namaPosbankum.value;
        kecamatan.value = posbankumData['kecamatan'] ?? '';
        kabupaten.value = posbankumData['kabupaten'] ?? '';
      } catch (e) {
        print("⚠️ Gagal fetch posbankum: $e, pakai fallback dari session");
      }
    }

    // Nama pelapor: kalau API mengembalikan nama_pelapor di data kegiatan, pakai itu
    if (item.namaPelapor != null && item.namaPelapor!.isNotEmpty) {
      namaPelapor.value = item.namaPelapor!;
    }
  }

  // Helper untuk format tanggal
  String getFormattedDate(String? rawDate) {
    if (rawDate == null) return '-';
    final dt = DateTime.parse(rawDate).toLocal();
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dt);
  }

  // ✅ Helper untuk warna status dinamis
  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'disetujui':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      case 'menunggu':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}