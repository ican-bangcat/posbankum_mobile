import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_dashboard_admin_controller.dart';

// ✅ IMPORT HALAMAN ADMIN / PARALEGAL KAMU DI SINI
import '../../auth/views/home_paralegal_screen.dart';

// import '../../kegiatan/views/kegiatan_view.dart'; // (Contoh kalau halamannya udah ada)

class MainDashboardAdminView extends GetView<MainDashboardAdminController> {
  const MainDashboardAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    // ── HALAMAN KHUSUS ADMIN / PARALEGAL ──
    final List<Widget> pages = [
      const Center(child: Text('Halaman Kegiatan')),     // Index 0 (Kegiatan)
      const Center(child: Text('Kelola Pengaduan')),     // Index 1 (Pengaduan Admin)
      const HomeParalegalScreen(),                       // Index 2 (Home Admin Asli!)
      const Center(child: Text('Halaman Chat Admin')),   // Index 3 (Chat)
      const Center(child: Text('Profile Admin')),        // Index 4 (Profile)
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4FB),

      // ✅ Menggunakan IndexedStack agar tidak error saat pindah tab
      body: Obx(() => IndexedStack(
        index: controller.selectedIndex.value,
        children: pages,
      )),

      // ✅ DESAIN NAVBAR DISAMAKAN DENGAN NAVBAR MASYARAKAT
      bottomNavigationBar: Obx(
            () => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 80,
              child: Row(
                children: [
                  _buildNavItem(
                    icon: Icons.event_note_outlined,
                    label: 'Kegiatan',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.assignment_outlined,
                    label: 'Pengaduan',
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: Icons.chat_bubble_outline,
                    label: 'Chat',
                    index: 3,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    index: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── WIDGET TOMBOL NAVIGASI (SAMA PERSIS DENGAN MASYARAKAT) ──
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = controller.selectedIndex.value == index;
    final color = isActive ? const Color(0xFF2A2E5E) : const Color(0xFFA8A8A8);

    // BUNGKUS DENGAN EXPANDED AGAR LEBARNYA DIBAGI RATA PERSIS
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.changeTab(index),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Agar vertikalnya tidak melar aneh
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Garis indikator kuning di atas icon
            Container(
              width: 24,
              height: 3,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFE8CE66) : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            // Teks Navigasi
            Text(
              label,
              maxLines: 1, // Mencegah teks turun ke baris bawah kalau layarnya kecil
              overflow: TextOverflow.ellipsis, // Kalau kepanjangan, ujungnya jadi "..."
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontFamily: 'Poppins',
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}