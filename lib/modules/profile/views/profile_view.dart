import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../app/routes/app_routes.dart';
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  // --- Palet Warna ---
  static const Color darkBlueColor = Color(0xFF2A2E5E);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFF64748B);
  static const Color primaryBlue = Color(0xFF1152D4);
  static const Color dangerColor = Color(0xFFE53E3E);

  @override
  Widget build(BuildContext context) {
    // ════════════════════════════════════════════════════
    // MATEMATIKA UKURAN RESPONSIF
    // ════════════════════════════════════════════════════
    final screenWidth = MediaQuery.of(context).size.width;

    // Bikin ukuran avatar 41% dari lebar layar, tapi MAKSIMAL 172px
    double avatarSize = screenWidth * 0.41;
    if (avatarSize > 172) avatarSize = 172;

    // Posisi puncak lengkungan di 170
    const double curvePeak = 170.0;

    // Hitung posisi Y agar selalu pas di tengah persimpangan (170 - setengah avatar)
    double avatarTopPosition = curvePeak - (avatarSize / 2);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // 1. BACKGROUND UNGU/BIRU TUA
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2A2E5E), Color(0xFF2A2E5E)],
                ),
              ),
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  'assets/images/icons/illustration_halaman_profile.png',
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const SizedBox(),
                ),
              ),
            ),

            // 2. LENGKUNGAN PUTIH + KONTEN
            Container(
              margin: const EdgeInsets.only(top: curvePeak),
              child: ClipPath(
                clipper: DomeClipper(),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - curvePeak,
                  ),
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Spacer dinamis ngikutin ukuran avatar
                      SizedBox(height: (avatarSize / 2) + 16),

                      // --- NAMA & ID USER (DARI SUPABASE) ---
                      Obx(() => Text(
                        controller.isLoading.value ? 'Memuat...' : controller.namaLengkap.value,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      )),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                        controller.isLoading.value ? 'ID: ---' : controller.displayId.value,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textLight,
                          letterSpacing: 1.0,
                        ),
                      )),
                      const SizedBox(height: 32),

                      // --- MENU PENGATURAN AKUN ---
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
                                Get.toNamed(AppRoutes.EDIT_PROFILE);
                              },
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.lock_outline,
                              title: 'Ganti Kata Sandi',
                              onTap: () {},
                            ),

                            const SizedBox(height: 32),

                            // --- MENU INFORMASI & BANTUAN ---
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

                            // --- TOMBOL KELUAR (LOGOUT) ---
                            _buildLogoutItem(onTap: () => controller.logout()),

                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. FOTO PROFIL (UKURAN RESPONSIF + DATA SUPABASE)
            Positioned(
              top: avatarTopPosition,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                padding: EdgeInsets.all(avatarSize * 0.035), // Ketebalan border putih ngikutin avatar
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Obx(() {
                  // Kalau lagi loading, tampilin loading muter-muter
                  if (controller.isLoading.value) {
                    return const CircleAvatar(
                      backgroundColor: Color(0xFFF1F5F9),
                      child: CircularProgressIndicator(color: primaryBlue),
                    );
                  }

                  // Cek apakah ada avatarUrl dari database
                  bool hasAvatar = controller.avatarUrl.value.isNotEmpty;
                  return CircleAvatar(
                    backgroundColor: const Color(0xFFF1F5F9),
                    // ✅ Ganti AssetImage jadi null
                    backgroundImage: hasAvatar
                        ? NetworkImage(controller.avatarUrl.value)
                        : null,

                    child: hasAvatar
                        ? null
                        : Icon(Icons.person, size: avatarSize * 0.45, color: textLight),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // WIDGET HELPER (Tetap Sama)
  // ════════════════════════════════════════════════════

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
                color: primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: primaryBlue, size: 22),
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
                borderRadius: BorderRadius.circular(8),
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

// ════════════════════════════════════════════════════
// CLASS DOMECLIPPER (Tetap Sama)
// ════════════════════════════════════════════════════
class DomeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 80);
    path.quadraticBezierTo(size.width / 2, 0, size.width, 80);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}