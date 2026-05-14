import 'package:get/get.dart';
import 'package:intl/intl.dart';
// ✅ Import WebSupabaseService
import '../../../app/data/services/supabase_service.dart';

class KegiatanItem {
  final String id;
  final String judul;
  final String kategori;
  final String tanggal;
  final String lokasi;
  final String? imageUrl;
  final String status; // ✅ Tambahan status untuk UI

  KegiatanItem({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.tanggal,
    required this.lokasi,
    this.imageUrl,
    required this.status,
  });

  // Fungsi untuk convert dari JSON Supabase ke Model Flutter
  factory KegiatanItem.fromJson(Map<String, dynamic> json) {
    String formattedDate = '-';

    // ✅ Ganti ke tgl_mulai dan format pure tanggal tanpa jam
    if (json['tgl_mulai'] != null) {
      final dt = DateTime.parse(json['tgl_mulai']).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(dt);
    }

    return KegiatanItem(
      id: json['id_kegiatan'].toString(), // ✅ Ganti ke id_kegiatan
      judul: json['judul'] ?? '',
      kategori: json['kategori'] ?? 'Lainnya',
      tanggal: formattedDate,
      lokasi: json['lokasi'] ?? '',
      imageUrl: json['thumbnail_path'], // ✅ Ganti ke thumbnail_path
      status: json['status'] ?? 'draft', // ✅ Ambil status kegiatan
    );
  }
}

class KelolaKegiatanController extends GetxController {
  var selectedTab = 'Semua'.obs;
  var searchQuery = ''.obs;
  var isLoading = true.obs;

  // List asli dari database
  var allKegiatan = <KegiatanItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchKegiatan();
  }

  Future<void> fetchKegiatan() async {
    try {
      isLoading.value = true;

      // ✅ 1. Dapatkan User Email dari Pintu Web
      final user = WebSupabaseService.client.auth.currentUser;
      if (user == null) {
        Get.snackbar('Sesi Berakhir', 'Silakan login kembali');
        return;
      }
      final String userEmail = user.email ?? '';

      // ✅ 2. Cari id_posbankum asli dari tabel Web berdasarkan email
      final dataPosbankum = await WebSupabaseService.client
          .from('posbankum')
          .select('id_posbankum')
          .eq('email_akun', userEmail)
          .maybeSingle();

      if (dataPosbankum == null) {
        print("Data Posbankum tidak ditemukan");
        return;
      }

      final String idPosbankumAsli = dataPosbankum['id_posbankum'];

      // ✅ 3. Ambil data dari tabel 'kegiatan' KHUSUS milik Posbankum ini
      final response = await WebSupabaseService.client
          .from('kegiatan')
          .select()
          .eq('id_posbankum', idPosbankumAsli) // Membatasi data
          .order('tgl_upload', ascending: false); // ✅ Ganti created_at jadi tgl_upload

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