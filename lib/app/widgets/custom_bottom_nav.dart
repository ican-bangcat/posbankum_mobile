import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Tinggi Bottom Nav
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
            offset: const Offset(0, -4), // Shadow ke atas
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.notifications_none_outlined,
            label: 'Notification',
            index: 0,
            route: '/notification', // Ganti dengan route aslimu
          ),
          _buildNavItem(
            icon: Icons.assignment_outlined,
            label: 'Pengaduan',
            index: 1,
            route: '/riwayat-pengaduan',
          ),
          _buildNavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            index: 2,
            route: '/home-masyarakat',
          ),
          _buildNavItem(
            icon: Icons.chat_bubble_outline,
            label: 'Chat',
            index: 3,
            route: '/chat', // Nanti untuk PB08
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            index: 4,
            route: '/profile',
          ),
        ],
      ),
    );
  }

  // Widget untuk masing-masing tombol
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required String route,
  }) {
    final isActive = selectedIndex == index;
    // Warna sesuai palette kamu
    final color = isActive ? const Color(0xFF2A2E5E) : const Color(0xFFA8A8A8);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Logika Navigasi: Pindah halaman kalau yang diklik bukan halaman saat ini
        if (!isActive) {
          Get.offAllNamed(route); // offAllNamed agar tidak menumpuk history back
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Garis kuning indikator aktif di atas icon (seperti di desain)
          Container(
            width: 24,
            height: 3,
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFE8CE66) : Colors.transparent, // Kuning kalau aktif
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontFamily: 'Poppins',
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}