import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_dashboard_controller.dart';
import '../../pengaduan/controllers/daftar_pengaduan_controller.dart';
// Import halaman riwayat yang sudah kamu buat
import '../../pengaduan/views/daftar_pengaduan_view.dart';
import '../../auth/views/home_masyarakat_screen.dart';
import '../../profile/views/profile_view.dart'; // ✅ Tambah Import Profile View
import '../../notifikasi_masyarakat/views/notifikasi_masyarakat_view.dart';
import '../../notifikasi_masyarakat/controllers/notifikasi_masyarakat_controller.dart';
import '../../daftar_chat_masyarakat/controllers/daftar_chat_masyarakat_controller.dart';
import '../../daftar_chat_masyarakat/views/daftar_chat_masyarakat_view.dart';

class MainDashboardView extends GetView<MainDashboardController> {
  const MainDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DaftarPengaduanController());
    Get.put(NotifikasiMasyarakatController()); // Inject Notification Controller
    Get.put(DaftarChatMasyarakatController()); // ✅ 1. Inject Chat Controller Masyarakat

    // Ini daftar halaman yang akan diganti-ganti di tengah layar
    final List<Widget> pages = [
      const NotifikasiMasyarakatView(),                  // Index 0
      const DaftarPengaduanView(),                       // Index 1
      const HomeMasyarakatScreen(),                      // Index 2 (Home)
      const DaftarChatMasyarakatView(),                  // ✅ 2. Ubah jadi View Chat Asli! (Index 3)
      const ProfileView(),                               // Index 4 (Ubah jadi ProfileView asli!)
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4FB),

      // Menggunakan IndexedStack agar state halaman tidak reset saat pindah tab
      body: Obx(() => IndexedStack(
        index: controller.selectedIndex.value,
        children: pages,
      )),

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
                    icon: Icons.notifications_none_outlined,
                    label: 'Notification',
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
                    icon: Icons.account_circle_outlined,
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

  // ── WIDGET TOMBOL NAVIGASI ──
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
        child: SizedBox(
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Garis indikator kuning di ujung atas
              Positioned(
                top: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isActive ? 30 : 0,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFE2C842) : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min, // Agar vertikalnya tidak melar aneh
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 26),
                  const SizedBox(height: 4),
                  // Teks Navigasi
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontFamily: 'Poppins',
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}