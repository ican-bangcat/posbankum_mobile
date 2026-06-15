import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/data/services/api_service.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = ApiService();
  final _storage = GetStorage();

  // ── VARIABEL REAKTIF UNTUK DATA DIRI ──
  var isLoading = true.obs;
  var role = 'warga'.obs;
  var namaLengkap = ''.obs;
  var displayId = ''.obs;
  var avatarUrl = ''.obs;
  var nik = ''.obs;
  var noHp = ''.obs;
  var alamat = ''.obs;
  var kelurahanInfo = ''.obs;
  var email = ''.obs;
  var memberSince = ''.obs;

  // ── VARIABEL REAKTIF UNTUK STATS & RIWAYAT ──
  var totalPengaduan = '0'.obs;
  var totalDiproses = '0'.obs;
  var totalSelesai = '0'.obs;
  var riwayatPengaduan = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  // Format Tanggal
  String _formatDate(String? isoString) {
    if (isoString == null) return '-';
    try {
      final date = DateTime.parse(isoString).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return '-';
    }
  }

  // ── FUNGSI AMBIL DATA PROFIL ──
  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;
      debugPrint('🔵 [PROFIL] 1. Menarik data profil dari Laravel API...');
      final response = await _apiService.dio.get('/profile');

      if (response.data['status'] == true) {
        final userData = response.data['data'];
        
        email.value = userData['email'] ?? '-';
        namaLengkap.value = userData['nama_lengkap'] ?? 'Pengguna Baru';
        noHp.value = userData['nomor_telepon'] ?? '-';
        avatarUrl.value = userData['foto_profile'] ?? '';
        role.value = userData['role'] ?? 'warga';

        String rawId = (userData['id_user'] ?? 'UNKNOWN').toString();
        if (rawId.length >= 8) {
          rawId = rawId.substring(0, 8).toUpperCase();
        }
        displayId.value = 'ID: PB-$rawId';

        if (userData['created_at'] != null) {
          final dt = DateTime.parse(userData['created_at']);
          memberSince.value = dt.year.toString();
        }

        // TAHAP 2: BACA DATA MASYARAKAT & WILAYAH (Jika role warga)
        if (role.value.toLowerCase() == 'warga' && userData['masyarakat'] != null) {
          final msk = userData['masyarakat'];
          nik.value = msk['nik'] ?? '-';
          alamat.value = msk['alamat'] ?? '-';

          final kel = msk['kelurahan'];
          final kec = msk['kecamatan'];
          final kab = msk['kabupaten'];

          String namaKel = (kel != null && kel is Map) ? (kel['nama'] ?? '') : '';
          String namaKec = (kec != null && kec is Map) ? (kec['nama'] ?? '') : '';
          String namaKab = (kab != null && kab is Map) ? (kab['nama'] ?? '') : '';

          List<String> regionParts = [];
          if (namaKel.isNotEmpty) regionParts.add(namaKel);
          if (namaKec.isNotEmpty) regionParts.add(namaKec);
          if (namaKab.isNotEmpty) regionParts.add(namaKab);

          if (regionParts.isNotEmpty) {
            kelurahanInfo.value = regionParts.join(', ');
          } else {
            kelurahanInfo.value = '-';
          }
        }
      }

      // TAHAP 3: AMBIL STATISTIK PENGADUAN
      debugPrint('🔵 [PROFIL] 2. Menarik statistik pengaduan...');
      final statsResponse = await _apiService.dio.get('/pengaduan/statistik');
      if (statsResponse.data['status'] == true) {
        final stats = statsResponse.data['data'];
        // Backend return: { menunggu: X, diproses: Y, selesai: Z, dibatalkan: W }
        int countProses = (stats['menunggu'] ?? 0) + (stats['diproses'] ?? 0);
        int countSelesai = stats['selesai'] ?? 0;
        int countTotal = (stats['menunggu'] ?? 0) + (stats['diproses'] ?? 0) + 
                         (stats['selesai'] ?? 0) + (stats['dibatalkan'] ?? 0);

        totalPengaduan.value = countTotal.toString();
        totalDiproses.value = countProses.toString();
        totalSelesai.value = countSelesai.toString();
      }

      // TAHAP 4: AMBIL RIWAYAT PENGADUAN
      debugPrint('🔵 [PROFIL] 3. Menarik riwayat pengaduan...');
      final pengaduanResponse = await _apiService.dio.get('/pengaduan');
      if (pengaduanResponse.data['status'] == true) {
        final List<dynamic> list = pengaduanResponse.data['data'];
        List<Map<String, dynamic>> riwayatTemp = [];

        for (var p in list) {
          String statusLaporan = (p['status'] ?? '').toString().toLowerCase();

          String statusTampil = 'Menunggu';
          Color warnaStatus = Colors.orange;

          if (statusLaporan == 'diproses') {
            statusTampil = 'Diproses';
            warnaStatus = Colors.blue;
          } else if (statusLaporan == 'selesai') {
            statusTampil = 'Selesai';
            warnaStatus = Colors.green;
          } else if (statusLaporan == 'dibatalkan') {
            statusTampil = 'Dibatalkan';
            warnaStatus = Colors.red;
          }

          riwayatTemp.add({
            'judul': p['judul_pengaduan'] ?? p['jenis_masalah'] ?? 'Pengaduan',
            'sub': '${p['nomor_pengaduan'] ?? '-'}  •  ${_formatDate(p['created_at'])}',
            'status': statusTampil,
            'color': warnaStatus,
          });
        }
        riwayatPengaduan.assignAll(riwayatTemp.take(3).toList());
      }

      debugPrint('✅ [PROFIL] Semua data sukses dimuat!');
    } catch (e, stackTrace) {
      debugPrint('❌ [ERROR PROFIL] Terjadi kesalahan: $e');
      debugPrint(stackTrace.toString());
      Get.snackbar('Informasi',
          'Beberapa data profil mungkin belum lengkap. Silakan coba lagi nanti.',
          backgroundColor: Colors.orange, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Merah
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.logout_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Keluar dari Akun?',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            
            // Body Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5),
                      children: [
                        const TextSpan(text: 'Anda akan keluar dari akun '),
                        TextSpan(
                          text: namaLengkap.value,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        const TextSpan(text: '.\nSesi aktif dan data yang belum disimpan akan hilang.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Warning Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFEE2E2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pastikan semua pengaduan sudah tersimpan sebelum keluar.',
                            style: TextStyle(color: const Color(0xFFB91C1C), fontSize: 12, fontWeight: FontWeight.w500, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Buttons
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A61A8),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chevron_left, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Batal, Tetap di Aplikasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () async {
                      Get.back();
                      try {
                        await _apiService.dio.post('/logout');
                        await _storage.remove('token');
                        await _storage.remove('user');
                        await _storage.remove('role');
                        await _storage.write('is_logged_in', false);
                        Get.offAllNamed(AppRoutes.LOGIN_FORM);
                      } catch (e) {
                        await _storage.erase();
                        Get.offAllNamed(AppRoutes.LOGIN_FORM);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFEE2E2)),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                        SizedBox(width: 8),
                        Text('Ya, Keluar Sekarang', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}