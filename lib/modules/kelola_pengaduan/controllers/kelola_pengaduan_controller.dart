import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KasusItem {
  final String id;
  final String judul;
  final String kategori;
  final String deskripsi;
  final String lokasi;
  final DateTime tanggalPengajuan;
  final DateTime? tanggalKejadian;
  final String status;
  final String? namaKlien;
  final String? noHpKlien;

  KasusItem({
    required this.id, required this.judul, required this.kategori,
    required this.deskripsi, required this.lokasi, required this.tanggalPengajuan,
    this.tanggalKejadian, required this.status, this.namaKlien, this.noHpKlien,
  });

  factory KasusItem.fromJson(Map<String, dynamic> json) {
    String namaMasyarakat = 'Masyarakat (Klien)';
    String noHpMasyarakat = '-';
    if (json['masyarakat'] != null) {
      if (json['masyarakat']['nama'] != null) namaMasyarakat = json['masyarakat']['nama'].toString();
      if (json['masyarakat']['no_hp'] != null) noHpMasyarakat = json['masyarakat']['no_hp'].toString();
    }

    return KasusItem(
      id: json['id']?.toString() ?? '',
      judul: json['kategori_masalah']?.toString() ?? 'Kasus Tanpa Kategori',
      kategori: json['kategori_masalah']?.toString() ?? 'Lain-lain',
      deskripsi: json['kronologi']?.toString() ?? 'Tidak ada kronologi',
      lokasi: json['lokasi_kejadian']?.toString() ?? 'Lokasi tidak diketahui',
      tanggalPengajuan: json['tgl_lapor'] != null ? DateTime.parse(json['tgl_lapor']) : DateTime.now(),
      tanggalKejadian: json['tgl_kejadian'] != null ? DateTime.parse(json['tgl_kejadian']) : null,
      status: json['status']?.toString().toLowerCase() ?? 'pending',
      namaKlien: namaMasyarakat,
      noHpKlien: noHpMasyarakat,
    );
  }
}

class KelolaPengaduanController extends GetxController {
  final supabase = Supabase.instance.client;

  var selectedTab = 0.obs;
  var searchQuery = ''.obs;
  var isLoading = true.obs;
  var allKasus = <KasusItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPengaduan();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  // ✅ KODE BERSIH SUPABASE (Sekarang pasti jalan karena relasi DB udah bener)
  Future<void> fetchPengaduan() async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('pengaduan')
          .select('*, masyarakat(nama, no_hp)')
          .order('tgl_lapor', ascending: true);

      final List<KasusItem> fetchedData = (response as List)
          .map((data) => KasusItem.fromJson(data))
          .toList();

      allKasus.assignAll(fetchedData);
    } catch (e) {
      print('Error fetch pengaduan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  int getPriorityValue(String kategori) {
    final kat = kategori.toLowerCase();
    if (kat.contains('fisik') || kat.contains('seksual') || kat.contains('narkotika')) return 1;
    if (kat.contains('gender') || kat.contains('perundungan') || kat.contains('siber') || kat.contains('digital')) return 2;
    if (kat.contains('keluarga') || kat.contains('perburuhan') || kat.contains('ketenagakerjaan') || kat.contains('tanah') || kat.contains('lingkungan')) return 3;
    if (kat.contains('properti') || kat.contains('perdata')) return 4;
    return 5;
  }

  List<KasusItem> get filteredKasus {
    List<KasusItem> filtered = allKasus.where((kasus) {
      bool matchTab = true;
      if (selectedTab.value == 1) matchTab = (kasus.status == 'proses' || kasus.status == 'dalam proses' || kasus.status == 'diproses');
      if (selectedTab.value == 2) matchTab = kasus.status == 'selesai';

      bool matchSearch = kasus.judul.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          kasus.lokasi.toLowerCase().contains(searchQuery.value.toLowerCase());

      return matchTab && matchSearch;
    }).toList();

    filtered.sort((a, b) {
      int prioA = getPriorityValue(a.kategori);
      int prioB = getPriorityValue(b.kategori);

      if (prioA != prioB) {
        return prioA.compareTo(prioB);
      } else {
        return a.tanggalPengajuan.compareTo(b.tanggalPengajuan);
      }
    });

    return filtered;
  }
}