import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app/themes/app_colors.dart';

// ✅ Sesuaikan path import controller ini dengan struktur folder kamu!
import '../../main_dashboard/controllers/main_dashboard_controller.dart';

class PengaduanSuccessScreen extends StatelessWidget {
  final String pengaduanId;

  const PengaduanSuccessScreen({
    super.key,
    required this.pengaduanId,
  });

  static const Color darkBlueColor = Color(0xFF2A2E5E);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    // Ambil ukuran layar biar background blur-nya dinamis
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ═════════════════════════════════════════════════════════════════
          // 1. BACKGROUND BOKEH / BLUR AESTHETIC
          // ═════════════════════════════════════════════════════════════════
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: Opacity(
              opacity: 0.3,
              child: SvgPicture.asset(
                'assets/images/backgrounds/bokeh_overlay.svg',
                width: size.width * 0.8 > 400 ? 400 : size.width * 0.8,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.2,
            child: Opacity(
              opacity: 0.3,
              child: SvgPicture.asset(
                'assets/images/backgrounds/bokeh_overlay.svg',
                width: size.width * 0.8 > 400 ? 400 : size.width * 0.8,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // ═════════════════════════════════════════════════════════════════
          // 2. KONTEN UTAMA
          // ═════════════════════════════════════════════════════════════════
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // --- Icon Sukses (Bisa diganti pakai aset yang pas) ---
                      Image.asset(
                          'assets/images/icons/success_icon_check.png', // ✅ Pastikan path icon ini bener
                          width: 140,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback kalau gambar nggak ketemu
                            return Container(
                              width: 100, height: 100,
                              decoration: BoxDecoration(color: darkBlueColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: darkBlueColor.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)]),
                              child: const Icon(Icons.check, size: 50, color: Colors.white),
                            );
                          }
                      ),
                      const SizedBox(height: 32),

                      // --- Teks Judul ---
                      const Text(
                        'Pengaduan Berhasil Dikirim',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- Teks Deskripsi ---
                      const Text(
                        'Pengaduan Anda telah berhasil\ndikirim dan akan segera ditinjau oleh\ntim paralegal kami',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- Kartu ID Pengaduan ---
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: pengaduanId));
                          Get.snackbar('Berhasil', 'ID Pengaduan disalin', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC), // Abu-abu super muda
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                          ),
                          child: Column(
                            children: [
                              const Text('ID Pengaduan', style: TextStyle(fontSize: 12, color: textSecondary)),
                              const SizedBox(height: 8),
                              Text(pengaduanId, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // --- Tombol Navigasi ---
                      _buildButtons(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        // ── TOMBOL UTAMA: Kembali ke Beranda ──
        ElevatedButton(
          onPressed: () {
            // ✅ 1. Balik ke halaman MainDashboard (Biar Navbar aman!)
            Get.offAllNamed('/main-dashboard'); // Ganti dengan AppRoutes.MAIN_DASHBOARD kalau kamu pakai class routes

            // ✅ 2. Kasih jeda dikit, lalu ubah tab ke Home (Index 2)
            Future.delayed(const Duration(milliseconds: 100), () {
              if (Get.isRegistered<MainDashboardController>()) {
                Get.find<MainDashboardController>().changeTab(2);
              }
            });
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: darkBlueColor,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0
          ),
          child: const Text('Kembali ke Beranda', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ),

        const SizedBox(height: 12),

        // ── TOMBOL KEDUA: Lihat Detail Pengaduan ──
        OutlinedButton(
          onPressed: () {
            // ✅ 1. Bersihin stack layar, balik ke Dashboard dulu sbg "Pondasi"
            Get.offAllNamed('/main-dashboard');

            // ✅ 2. Buka halaman Detail ditumpuk di atas Dashboard
            Future.delayed(const Duration(milliseconds: 100), () {
              Get.toNamed('/detail-kasus', arguments: pengaduanId);
            });
          },
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
          ),
          child: const Text('Lihat Detail Pengaduan', style: TextStyle(color: darkBlueColor, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}