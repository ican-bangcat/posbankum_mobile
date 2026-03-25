import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/routes/app_routes.dart';
import 'login_screen.dart';

// Import Controller Dashboard
import '../../main_dashboard/controllers/main_dashboard_controller.dart';

class HomeMasyarakatScreen extends StatefulWidget {
  const HomeMasyarakatScreen({super.key});

  @override
  State<HomeMasyarakatScreen> createState() => _HomeMasyarakatScreenState();
}

class _HomeMasyarakatScreenState extends State<HomeMasyarakatScreen>
    with SingleTickerProviderStateMixin {
  final storage = GetStorage();
  final supabase = Supabase.instance.client;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String userName = 'Nama Masyarakat';

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Setup animasi masuk (Fade & Slide)
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)),
    );

    _animationController.forward();
  }

  Future<void> _loadUserData() async {
    String? storedName = storage.read('user_name');
    if (storedName != null && storedName.isNotEmpty) {
      setState(() {
        userName = storedName;
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator(color: Colors.white)), barrierDismissible: false);
      await supabase.auth.signOut();
      await storage.erase();
      Get.back();
      Get.offAll(() => const LoginScreen());
      Get.snackbar('Berhasil', 'Anda telah logout', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Gagal logout: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showProfileOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text('Menu Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF1E3A5F)),
              title: const Text('Lihat Profil'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Get.back();
                Get.snackbar('Info', 'Halaman Profil akan segera tersedia');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                _confirmLogout();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () { Get.back(); _handleLogout(); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: Container(
              // Background biru penopang S-Curve
              color: const Color(0xFF1E3A5F),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F4F7), // Warna asli bagian putih
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20), // Ujung kiri atas putih melengkung 20
                  ),
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const SizedBox(height: 20),
                        _buildConsultationCard(),
                        const SizedBox(height: 24),
                        _buildCaseSummarySection(),
                        const SizedBox(height: 24),
                        _buildRecentHistorySection(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 160, // <-- UBAH NILAI INI JIKA INGIN LEBIH PENDEK/TINGGI (Sebelumnya 210)
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A5F), // Biru gelap
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(20), // Ujung kanan bawah biru melengkung 20
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // 1. ILUSTRASI GEDUNG
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.25,
              child: Image.asset(
                'assets/images/icons/building_illustration3.png',
                fit: BoxFit.cover,
                height: 110, // Menyesuaikan tinggi gambar agar tidak terlalu besar
                alignment: Alignment.bottomCenter,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),

          // 2. KONTEN UTAMA (Di tengah vertikal)
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.center, // <-- MENGATUR POSISI KE TENGAH VERTIKAL
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profil (Kiri)
                    GestureDetector(
                      onTap: _showProfileOptions,
                      child: Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 30),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Nama (Tengah, Expanded agar Notif kedorong ke kanan)
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Agar column tidak makan tempat lebih dari isinya
                        crossAxisAlignment: CrossAxisAlignment.start, // Teks rata kiri
                        children: [
                          Text(
                            'Halo,',
                            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Notifikasi (Kanan)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                        ),
                        Positioned(
                          right: 8, top: 8,
                          child: Container(
                            width: 9, height: 9,
                            decoration: const BoxDecoration(color: Color(0xFFFF4444), shape: BoxShape.circle),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CONSULTATION CARD (TOMBOL BUAT PENGADUAN) ───────────────────────────────
  Widget _buildConsultationCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2B6CB0), Color(0xFF4299E1)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: const Color(0xFF2B6CB0).withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text('⚖️', style: TextStyle(fontSize: 22))),
              ),
              const SizedBox(height: 14),
              const Text(
                'Buat Pengaduan Baru',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, height: 1.2),
              ),
              const SizedBox(height: 6),
              Text(
                'Dapatkan bantuan hukum gratis dari\nparalegal profesional kami',
                style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: () => Get.toNamed(AppRoutes.FORM_PENGADUAN),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Mulai Sekarang', style: TextStyle(color: Color(0xFF2B6CB0), fontWeight: FontWeight.w600, fontSize: 14)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, color: Color(0xFF2B6CB0), size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── CASE SUMMARY ────────────────────────────────────────────────────────────
  Widget _buildCaseSummarySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Kasus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A202C))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCaseCard(
                  icon: Icons.gavel_rounded, iconColor: const Color(0xFFED8936), iconBg: const Color(0xFFFFF3E0),
                  label: 'Kasus Aktif', count: '1',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildCaseCard(
                  icon: Icons.check_circle_rounded, iconColor: const Color(0xFF38A169), iconBg: const Color(0xFFE6FFFA),
                  label: 'Selesai', count: '0',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCard({required IconData icon, required Color iconColor, required Color iconBg, required String label, required String count}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 8),
              Flexible(child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF718096), fontWeight: FontWeight.w500))),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: count, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFF1A202C))),
                const TextSpan(text: ' kasus', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF718096))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── RECENT HISTORY ──────────────────────────────────────────────────────────
  Widget _buildRecentHistorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Riwayat Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A202C))),
              TextButton(
                onPressed: () {
                  if (Get.isRegistered<MainDashboardController>()) {
                    Get.find<MainDashboardController>().changeTab(1);
                  } else {
                    Get.toNamed(AppRoutes.RIWAYAT_PENGADUAN);
                  }
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('Lihat Semua', style: TextStyle(color: Color(0xFF3182CE), fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildHistoryCard(
            iconEmoji: '📝', title: 'Pembuatan Draft', subtitle: 'Hukum Perdata',
            badgeText: 'Pending', badgeColor: const Color(0xFFEF6C00), badgeBg: const Color(0xFFFFF3E0),
            timeAgo: 'Baru saja',
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({required String iconEmoji, required String title, required String subtitle, required String badgeText, required Color badgeColor, required Color badgeBg, required String timeAgo}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: const Color(0xFFF7FAFC), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(iconEmoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A202C))),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF718096))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
                child: Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 6),
              Text(timeAgo, style: const TextStyle(fontSize: 11, color: Color(0xFFA0AEC0))),
            ],
          ),
        ],
      ),
    );
  }
}