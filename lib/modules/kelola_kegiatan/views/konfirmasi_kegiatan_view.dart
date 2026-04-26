import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app/routes/app_routes.dart';
import '../../main_dashboard_admin/controllers/main_dashboard_admin_controller.dart';
import '../controllers/kelola_kegiatan_controller.dart';

class KonfirmasiKegiatanView extends StatelessWidget {
  const KonfirmasiKegiatanView({super.key});

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
          // 1. BACKGROUND BOKEH / BLUR AESTHETIC (Merespons Ukuran Layar)
          // ═════════════════════════════════════════════════════════════════

          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: Opacity(
              opacity: 0.3,
              child: SvgPicture.asset(
                'assets/images/backgrounds/bokeh_overlay.svg',
                width: size.width * 0.8 > 400 ? 400 : size.width * 0.8, // Maksimal 400px
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
          // 2. KONTEN UTAMA (Responsif HP & Tablet)
          // ═════════════════════════════════════════════════════════════════
          SafeArea(
            child: Center( // ✅ Bikin ke tengah untuk Tablet
              child: ConstrainedBox( // ✅ Tahan lebar maksimal konten
                constraints: const BoxConstraints(
                  maxWidth: 480, // Ukuran maksimal konten (Ideal untuk UI Card di Tablet)
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // --- Icon Sukses ---
                      Image.asset(
                        'assets/images/icons/success_icon_check.png',
                        width: 140,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 32),

                      // --- Teks Judul ---
                      const Text(
                        'Kegiatan Berhasil\nDikirim',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- Teks Deskripsi ---
                      const Text(
                        'Laporan kegiatan Anda telah berhasil\ndisimpan dan akan segera diproses oleh\nsistem administrasi hukum kami.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: textSecondary,
                          height: 1.6,
                        ),
                      ),

                      const Spacer(),

                      // --- Tombol Navigasi ---
                      _buildButtons(),

                      const SizedBox(height: 20), // Spasi bawah
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
            // 1. Balik ke halaman Dashboard (Reset tumpukan layar)
            Get.offAllNamed(AppRoutes.MAIN_DASHBOARD_ADMIN);

            // 2. Kasih jeda dikit biar controllernya siap, baru ubah tab ke Home (Index 2)
            Future.delayed(const Duration(milliseconds: 100), () {
              if (Get.isRegistered<MainDashboardAdminController>()) {
                Get.find<MainDashboardAdminController>().selectedIndex.value = 2;
              }
            });
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: darkBlueColor,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0
          ),
          child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_outlined, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Kembali ke Beranda', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))
              ]
          ),
        ),

        const SizedBox(height: 16),

        // ── TOMBOL KEDUA: Lihat Daftar Kegiatan ──
        OutlinedButton(
          onPressed: () {
            // 1. Balik ke halaman Dashboard
            Get.offAllNamed(AppRoutes.MAIN_DASHBOARD_ADMIN);

            // 2. Kasih jeda, lalu pindah tab ke Kegiatan (Index 0) & Refresh Data
            Future.delayed(const Duration(milliseconds: 100), () {
              if (Get.isRegistered<MainDashboardAdminController>()) {
                Get.find<MainDashboardAdminController>().selectedIndex.value = 0;
              }
              // Tarik data terbaru dari database
              if (Get.isRegistered<KelolaKegiatanController>()) {
                Get.find<KelolaKegiatanController>().fetchKegiatan();
              }
            });
          },
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
          ),
          child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt_outlined, color: darkBlueColor, size: 20),
                SizedBox(width: 10),
                Text('Lihat Daftar Kegiatan', style: TextStyle(color: darkBlueColor, fontSize: 14, fontWeight: FontWeight.w700))
              ]
          ),
        ),
      ],
    );
  }
}