import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../main.dart'; // Sesuaikan path ini agar bisa memanggil supabaseB dari main.dart

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
      judul: json['judul_laporan']?.toString() ?? 'Tanpa Judul',
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
  // Panggil Supabase A (Database Mobile) dari instance bawaan
  final supabaseA = Supabase.instance.client;

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

  // Di dalam KelolaPengaduanController lo
  Future<void> fetchPengaduan() async {
    try {
      isLoading.value = true;

      final sessionDB = supabaseB.auth.currentSession;
      final userMeta = supabaseB.auth.currentUser?.userMetadata;

      if (sessionDB == null || userMeta == null) throw 'Sesi tidak valid';

      final posbankumId = userMeta['id_posbankum'] ?? '';
      final token = sessionDB.accessToken;

      // Ambil nama Posbankum dari DB B (Contoh: "Posbankum Air Hitam")
      // Kita bersihkan teksnya atau ambil kata kuncinya saja untuk dicocokkan ke nama_lurah
      String namaPosbankum = userMeta['nama'] ?? userMeta['nama_posbankum'] ?? '';
      String keywordKelurahan = namaPosbankum.replaceAll('Posbankum', '').trim(); // Menjadi "Air Hitam"

      // TEMBAK EDGE FUNCTION DENGAN PARAMETER BARU
      final response = await supabaseA.functions.invoke(
        'get-pengaduan-paralegal',
        body: {
          'posbankum_id': posbankumId,
          'kelurahan': keywordKelurahan, // 🚀 LEMPAR KEYWORD KELURAHAN KELUAR
          'token': token
        },
      );

      if (response.data != null) {
        final List<KasusItem> fetchedData = (response.data as List)
            .map((data) => KasusItem.fromJson(data))
            .toList();
        allKasus.assignAll(fetchedData);
      }
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
      if (kasus.status == 'dibatalkan') return false;

      bool matchTab = true;
      if (selectedTab.value == 1) matchTab = (kasus.status == 'proses' || kasus.status == 'dalam proses' || kasus.status == 'diproses');
      if (selectedTab.value == 2) matchTab = kasus.status == 'selesai';

      bool matchSearch = kasus.judul.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          kasus.kategori.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
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