import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/routes/app_routes.dart';

class ProfileController extends GetxController {
  final supabase = Supabase.instance.client;

  // ── VARIABEL REAKTIF UNTUK DATA DIRI ──
  var isLoading = true.obs;
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

  // ── FUNGSI AMBIL DATA PROFIL (PECAH 3 TAHAP AMAN) ──
  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;
      debugPrint('🔵 [PROFIL] 1. Mengecek sesi user...');
      final user = supabase.auth.currentUser;

      if (user == null) {
        debugPrint('🟡 [PROFIL] User tidak ditemukan / belum login.');
        return;
      }

      if (user != null) {
        email.value = user.email ?? '-';
      }

      // TAHAP 1: AMBIL DATA PROFIL UTAMA
      debugPrint('🔵 [PROFIL] 2. Menarik data tabel profiles...');
      final profileData = await supabase
          .from('profiles')
          .select('id, full_name, nomor_telepon, foto_profile, created_at')
          .eq('id', user.id)
          .maybeSingle();

      if (profileData != null) {
        namaLengkap.value = profileData['full_name'] ?? 'Pengguna Baru';
        noHp.value = profileData['nomor_telepon'] ?? '-';
        avatarUrl.value = profileData['foto_profile'] ?? '';

        String rawId = profileData['id'].toString().substring(0, 8).toUpperCase();
        displayId.value = 'ID: PB-$rawId';

        // Set Anggota Sejak
        if (profileData['created_at'] != null) {
          final dt = DateTime.parse(profileData['created_at']);
          memberSince.value = dt.year.toString();
        }
      }

      // TAHAP 2: AMBIL DATA MASYARAKAT & WILAYAH
      debugPrint('🔵 [PROFIL] 3. Menarik data tabel masyarakat...');
      final masyarakatData = await supabase
          .from('masyarakat')
          .select('nik, alamat, kelurahan(nama), kecamatan(nama), kabupaten(nama)')
          .eq('id', user.id)
          .maybeSingle();

      if (masyarakatData != null) {
        nik.value = masyarakatData['nik'] ?? '-';
        alamat.value = masyarakatData['alamat'] ?? '-';

        final kel = masyarakatData['kelurahan'];
        final kec = masyarakatData['kecamatan'];
        final kab = masyarakatData['kabupaten'];

        // Parsing aman untuk mencegah error Type Cast (Map vs List)
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

      // TAHAP 3: AMBIL STATISTIK PENGADUAN
      debugPrint('🔵 [PROFIL] 4. Menarik data tabel pengaduan...');
      final List<dynamic> pengaduanData = await supabase
          .from('pengaduan')
          .select('id_pengaduan, judul_pengaduan, jenis_masalah, nomor_pengaduan, status, created_at')
          .eq('masyarakat_id', user.id)
          .order('created_at', ascending: false);

      int countProses = 0;
      int countSelesai = 0;
      List<Map<String, dynamic>> riwayatTemp = [];

      for (var p in pengaduanData) {
        String statusLaporan = (p['status'] ?? '').toString().toLowerCase();

        // 1. Hitung Statistik
        if (statusLaporan == 'diproses' || statusLaporan == 'menunggu') {
          countProses++;
        } else if (statusLaporan == 'selesai') {
          countSelesai++;
        }

        // 2. Format Teks Status untuk UI
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

      totalPengaduan.value = pengaduanData.length.toString();
      totalDiproses.value = countProses.toString();
      totalSelesai.value = countSelesai.toString();
      riwayatPengaduan.assignAll(riwayatTemp.take(3).toList());

      debugPrint('✅ [PROFIL] Semua data sukses dimuat!');
    } catch (e, stackTrace) {
      debugPrint('❌ [ERROR PROFIL] Terjadi kesalahan: $e');
      debugPrint(stackTrace.toString());
      Get.snackbar('Informasi',
          'Beberapa data profil mungkin belum lengkap. Silakan coba lagi nanti.',
          backgroundColor: Colors.orange, colorText: Colors.white);
    } finally {
      // Apapun yang terjadi (sukses/error), matikan loading!
      isLoading.value = false;
    }
  }

  void logout() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/icons/icon_ask_logout.png',
                width: Get.width * 0.35,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Icon(Icons.help_outline,
                    size: 80, color: Color(0xFF2A2E5E)),
              ),
              const SizedBox(height: 24),
              const Text('Apakah Anda ingin Keluar ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2E5E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Batal',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        try {
                          await supabase.auth.signOut();
                          Get.offAllNamed(AppRoutes.LOGIN_FORM);
                        } catch (e) {
                          Get.snackbar('Error', 'Gagal logout: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2E5E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Keluar akun',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}