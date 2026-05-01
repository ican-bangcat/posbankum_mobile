import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

// ✅ Pastikan di sini menggunakan GetView<ProfileController>
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  // --- Palet Warna ---
  static const Color darkBlueColor = Color(0xFF2A2E5E);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFF64748B);
  static const Color iconBgColor = Color(0xFFF1F5F9);
  static const Color dangerColor = Color(0xFFE53E3E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ════════════════════════════════════════════════════
            // 1. HEADER (Lengkungan Biru + Foto Profil)
            // ════════════════════════════════════════════════════
            Stack(
              alignment: Alignment.topCenter,
              children: [
                // Background Biru + Ilustrasi
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: darkBlueColor,
                  ),
                  child: Stack(
                    children: [
                      // Ilustrasi background
                      Positioned(
                        right: -30,
                        top: 20,
                        child: Opacity(
                          opacity: 0.15,
                          child: Image.asset(
                            'assets/images/icons/logo_halaman_login.png',
                            height: 200,
                            errorBuilder: (c, e, s) => const SizedBox(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Lengkungan Putih (Dome effect)
                Container(
                  margin: const EdgeInsets.only(top: 170),
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.elliptical(MediaQuery.of(context).size.width, 80),
                    ),
                  ),
                ),

                // Foto Profil
                Positioned(
                  top: 110,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 54,
                      backgroundColor: iconBgColor,
                      backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
                      child: Icon(Icons.person, size: 50, color: textLight),
                    ),
                  ),
                ),
              ],
            ),

            // ════════════════════════════════════════════════════
            // 2. NAMA & ID USER
            // ════════════════════════════════════════════════════
            const SizedBox(height: 10),
            const Text(
              'Ahmad Fauzi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'ID: PB-2023-0045',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textLight,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 32),

            // ════════════════════════════════════════════════════
            // 3. MENU PENGATURAN AKUN
            // ════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('PENGATURAN AKUN'),
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profil',
                    onTap: () {
                      Get.snackbar('Info', 'Fitur Edit Profil segera hadir!');
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Ganti Kata Sandi',
                    onTap: () {},
                  ),

                  const SizedBox(height: 32),

                  // ════════════════════════════════════════════════════
                  // 4. MENU INFORMASI & BANTUAN
                  // ════════════════════════════════════════════════════
                  _buildSectionTitle('INFORMASI & BANTUAN'),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Pusat Bantuan',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'Tentang Aplikasi',
                    onTap: () {},
                  ),

                  const SizedBox(height: 32),

                  // ════════════════════════════════════════════════════
                  // 5. TOMBOL KELUAR (LOGOUT)
                  // ════════════════════════════════════════════════════
                  // ✅ Menggunakan controller bawaan dari GetView
                  _buildLogoutItem(onTap: () => controller.logout()),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: darkBlueColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutItem({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: dangerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: dangerColor, size: 22),
            ),
            const SizedBox(width: 16),
            const Text(
              'Keluar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: dangerColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 58.0, top: 4.0, bottom: 4.0),
      child: Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
    );
  }
}