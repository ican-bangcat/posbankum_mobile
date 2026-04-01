import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/routes/app_routes.dart';
import 'login_screen.dart';

// Import Controller Dashboard
import '../../main_dashboard_admin/controllers/main_dashboard_admin_controller.dart';

class HomeParalegalScreen extends StatefulWidget {
  const HomeParalegalScreen({super.key});

  @override
  State<HomeParalegalScreen> createState() => _HomeParalegalScreenState();
}

class _HomeParalegalScreenState extends State<HomeParalegalScreen>
    with SingleTickerProviderStateMixin {
  final storage = GetStorage();
  final supabase = Supabase.instance.client;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String userName = 'Nama Paralegal';

  // Stats data
  final int kasusBaru = 5;
  final int pendingProses = 8;
  final int kasusSelesai = 24;

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
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)),
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
      Get.dialog(
          const Center(
              child: CircularProgressIndicator(color: Colors.white)),
          barrierDismissible: false);
      await supabase.auth.signOut();
      await storage.erase();
      Get.back();
      Get.offAll(() => const LoginScreen());
      Get.snackbar('Berhasil', 'Anda telah logout',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Gagal logout: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
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
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text('Menu Profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF2A2E5E)),
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
              title: const Text('Logout',
                  style: TextStyle(color: Colors.red)),
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
            onPressed: () {
              Get.back();
              _handleLogout();
            },
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
          // ─── HEADER ───
          _buildHeader(),

          Expanded(
            child: Container(
              // Background biru penopang S-Curve
              color: const Color(0xFF2A2E5E),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F6F9), // Warna asli bagian putih
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
                        const SizedBox(height: 24),
                        _buildActionCard(), // Buat Laporan Kegiatan Baru
                        const SizedBox(height: 24),
                        _buildStatsSection(), // Ringkasan Kerja (3 Kartu)
                        const SizedBox(height: 24),
                        _buildRecentActivitySection(), // Aktivitas Terbaru
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
      height: 160,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2E5E), // Biru gelap
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
              opacity: 0.6,
              child: Image.asset(
                'assets/images/icons/building_illustration3.png',
                fit: BoxFit.cover,
                height: 110,
                alignment: Alignment.bottomCenter,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),

          // 2. KONTEN UTAMA (Di tengah vertikal)
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profil (Kiri)
                    GestureDetector(
                      onTap: _showProfileOptions,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 2),
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: const Icon(Icons.person,
                            color: Colors.white, size: 30),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Nama (Tengah, Expanded agar Notif kedorong ke kanan)
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo,',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 13),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
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
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: Colors.white, size: 22),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                                color: Color(0xFFFF4444),
                                shape: BoxShape.circle),
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

  // ─── ACTION CARD (BUAT LAPORAN KEGIATAN BARU) ───────────────────────────────
  Widget _buildActionCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          // Gradasi biru-ungu menyesuaikan referensi gambar Figma
          gradient: const LinearGradient(
            colors: [Color(0xFF454F96), Color(0xFF2A2E5E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2A2E5E).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Header
              const Icon(Icons.post_add_rounded, color: Colors.white, size: 38),
              const SizedBox(height: 16),

              // Teks Judul
              const Text(
                'Buat Laporan Kegiatan Baru',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              Text(
                'Catat aktivitas lapangan hari ini',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),

              // ✅ TOMBOL CENTERED
              Center(
                child: InkWell(
                  onTap: () {
                    Get.snackbar('Info', 'Form laporan akan segera tersedia');
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: double.infinity, // Supaya tombol memanjang rapi
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    // Row dibungkus MainAxisAlignment.center
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Mulai Laporan',
                          style: TextStyle(
                            color: Color(0xFF1E2154),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF1E2154),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── RINGKASAN KERJA (3 KARTU) ─────────────────────────────────────────────
  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Kerja',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1F36),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // 1. Kasus Baru
              Expanded(
                child: _buildStatCard(
                  iconEmoji: 'NEW',
                  iconBg: const Color(0xFFEFF6FF),
                  iconColor: const Color(0xFF3B82F6), // Biru
                  number: kasusBaru.toString(),
                  label: 'KASUS BARU',
                  isTextIcon: true,
                ),
              ),
              const SizedBox(width: 12),

              // 2. Dalam Proses
              Expanded(
                child: _buildStatCard(
                  icon: Icons.sync_rounded,
                  iconBg: const Color(0xFFFFF7ED),
                  iconColor: const Color(0xFFF97316), // Orange/Amber
                  number: pendingProses.toString(),
                  label: 'DALAM\nPROSES',
                ),
              ),
              const SizedBox(width: 12),

              // 3. Selesai
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_outline_rounded,
                  iconBg: const Color(0xFFECFDF5),
                  iconColor: const Color(0xFF10B981), // Hijau
                  number: kasusSelesai.toString(),
                  label: 'SELESAI',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    IconData? icon,
    String? iconEmoji,
    bool isTextIcon = false,
    required Color iconBg,
    required Color iconColor,
    required String number,
    required String label,
  }) {
    return Container(
      // ✅ Padding dikurangi sedikit agar konten berada di tengah
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Sudut lebih membulat
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lingkaran Ikon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isTextIcon
                  ? Text(
                iconEmoji!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: iconColor,
                  letterSpacing: 0.5,
                ),
              )
                  : Icon(icon, color: iconColor, size: 22),
            ),
          ),
          const SizedBox(height: 10),

          // Angka
          Text(
            number,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),

          // ✅ Label DIBUNGKUS SIZEDBOX AGAR KARTU TIDAK MELEBAR SAAT 2 BARIS TEKS
          SizedBox(
            height: 32,
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.3,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── AKTIVITAS TERBARU (Menggantikan Menu Utama Grid) ────────────────────────
  Widget _buildRecentActivitySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header "Aktivitas Terbaru" & "Lihat Semua"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aktivitas Terbaru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1F36),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (Get.isRegistered<MainDashboardAdminController>()) {
                    Get.find<MainDashboardAdminController>().changeTab(1);
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: Color(0xFF1E2154),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // List Aktivitas (Card 1)
          _buildHistoryCard(
            icon: Icons.groups_rounded,
            title: 'Pendampingan Klien',
            subtitle: 'Keluarga Bpk. Sutedjo',
            badgeText: 'HARI INI',
            badgeColor: const Color(0xFF3B82F6),
            badgeBg: const Color(0xFFEFF6FF),
            timeText: '10:00 AM',
          ),
          const SizedBox(height: 12),

          // List Aktivitas (Card 2)
          _buildHistoryCard(
            icon: Icons.fact_check_outlined,
            title: 'Verifikasi Berkas',
            subtitle: 'Kasus Pidana #092',
            badgeText: 'SELESAI',
            badgeColor: const Color(0xFF10B981),
            badgeBg: const Color(0xFFECFDF5),
            timeText: 'Kemarin',
          ),
        ],
      ),
    );
  }

  // ─── HISTORY CARD (SAMA PERSIS SEPERTI HOME MASYARAKAT) ───────────────────
  Widget _buildHistoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
    required String timeText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9), // Abu-abu sangat muda
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(icon, color: const Color(0xFF64748B), size: 24),
            ),
          ),
          const SizedBox(width: 14),

          // Teks Judul & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Badge Status & Waktu
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                timeText,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}