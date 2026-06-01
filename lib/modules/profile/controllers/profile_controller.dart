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

  // --- Fungsi Pembuat Format Tanggal (Contoh: 24 Okt 2023) ---
  String _formatDate(String? isoString) {
    if (isoString == null) return '-';
    try {
      final date = DateTime.parse(isoString).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return '-';
    }
  }

  // ── FUNGSI AMBIL DATA PROFIL ──
  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;
      final user = supabase.auth.currentUser;

      if (user != null) {
        // 1. AMBIL DATA DIRI DARI PROFILES & MASYARAKAT
        final data = await supabase
            .from('profiles')
            .select('''
              id, full_name, nomor_telepon, foto_profile,
              masyarakat ( nik, alamat, kelurahan (nama), kecamatan (nama), kabupaten (nama) )
            ''')
            .eq('id', user.id)
            .maybeSingle();

        if (data != null) {
          namaLengkap.value = data['full_name'] ?? 'Pengguna Baru';
          noHp.value = data['nomor_telepon'] ?? '-';
          avatarUrl.value = data['foto_profile'] ?? '';

          String rawId = data['id'].toString().substring(0, 8).toUpperCase();
          displayId.value = 'ID: PB-$rawId';

          final masyarakatData = data['masyarakat'] as Map<String, dynamic>?;
          if (masyarakatData != null) {
            nik.value = masyarakatData['nik'] ?? '-';
            alamat.value = masyarakatData['alamat'] ?? '-';

            String namaKelurahan = masyarakatData['kelurahan']?['nama'] ?? '';
            String namaKecamatan = masyarakatData['kecamatan']?['nama'] ?? '';

            if (namaKelurahan.isNotEmpty && namaKecamatan.isNotEmpty) {
              kelurahanInfo.value = '$namaKelurahan, $namaKecamatan';
            } else if (namaKelurahan.isNotEmpty) {
              kelurahanInfo.value = namaKelurahan;
            } else {
              kelurahanInfo.value = '-';
            }
          }
        }

        // 2. AMBIL STATISTIK DARI TABEL PENGADUAN ASLI
        final List<dynamic> pengaduanData = await supabase
            .from('pengaduan')
            .select('id_pengaduan, judul_pengaduan, nomor_pengaduan, status, created_at')
            .eq('masyarakat_id', user.id)
            .order('created_at', ascending: false);

        int countProses = 0;
        int countSelesai = 0;
        List<Map<String, dynamic>> riwayatTemp = [];

        for (var p in pengaduanData) {
          String statusLaporan = (p['status'] ?? '').toString().toLowerCase();

          if (statusLaporan == 'diproses') {
            countProses++;
          } else if (statusLaporan == 'selesai') {
            countSelesai++;
          }

          riwayatTemp.add({
            'judul': p['judul_pengaduan'] ?? 'Pengaduan',
            'sub': '${p['nomor_pengaduan'] ?? '-'}  •  ${_formatDate(p['created_at'])}',
            'status': statusLaporan == 'diproses' ? 'Diproses' : 'Selesai',
            'color': statusLaporan == 'selesai' ? Colors.green : Colors.orange,
          });
        }

        totalPengaduan.value = pengaduanData.length.toString();
        totalDiproses.value = countProses.toString();
        totalSelesai.value = countSelesai.toString();

        // Ambil 3 terbaru untuk ditampilkan di profil
        riwayatPengaduan.assignAll(riwayatTemp.take(3).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data profil: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
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
                errorBuilder: (c, e, s) => const Icon(Icons.help_outline, size: 80, color: Color(0xFF2A2E5E)),
              ),
              const SizedBox(height: 24),
              const Text('Apakah Anda ingin Keluar ?', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2E5E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Batal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Keluar akun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
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