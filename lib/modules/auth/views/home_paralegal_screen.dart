// home_paralegal_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/routes/app_routes.dart';
import 'login_screen.dart';
import '../controllers/home_paralegal_controller.dart'; // ✅ Import controller baru
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

  // ✅ Gunakan controller GetX — bukan state lokal lagi
  late final HomeParalegalController _dashboardCtrl;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;




  @override
  void initState() {
    super.initState();

    // ✅ Daftarkan controller (jika belum ada, otomatis dibuat)
    _dashboardCtrl = Get.put(HomeParalegalController());



    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _animationController,
              curve:
              const Interval(0.2, 1.0, curve: Curves.easeOutCubic)),
        );
    _animationController.forward();
  }


  Future<void> _handleLogout() async {
    try {
      Get.dialog(
          const Center(child: CircularProgressIndicator(color: Colors.white)),
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
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Menu Profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF2A2E5E)),
              title: const Text('Lihat Profil'),
              onTap: () {
                Get.back();
                Get.snackbar('Info', 'Halaman Profil akan segera tersedia');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title:
              const Text('Logout', style: TextStyle(color: Colors.red)),
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
          _buildHeader(),
          Expanded(
            child: Container(
              color: const Color(0xFF2A2E5E),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F6F9),
                  borderRadius:
                  BorderRadius.only(topLeft: Radius.circular(20)),
                ),
                child: RefreshIndicator(
                  // ✅ Memanggil method di controller, bukan fungsi lokal
                  onRefresh: _dashboardCtrl.fetchDashboardData,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 24),
                          _buildActionCard(),
                          const SizedBox(height: 24),
                          _buildStatsSection(), // ✅ Dibungkus Obx di dalam
                          const SizedBox(height: 24),
                          _buildRecentActivitySection(), // ✅ Dibungkus Obx di dalam
                          const SizedBox(height: 40),
                        ],
                      ),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2E5E),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Opacity(
              opacity: 0.6,
              child: Image.asset(
                'assets/images/icons/building_illustration3.png',
                fit: BoxFit.cover, height: 110, alignment: Alignment.bottomCenter,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
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
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Halo,', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                          // ✅ DIBUNGKUS OBX AGAR NAMA REAKTIF DARI DATABASE
                          Obx(() => Text(
                            _dashboardCtrl.userName.value,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                        ],
                      ),
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                        ),
                        Positioned(right: 8, top: 8, child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFFFF4444), shape: BoxShape.circle))),
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

  Widget _buildActionCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF454F96), Color(0xFF2A2E5E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: const Color(0xFF2A2E5E).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.post_add_rounded, color: Colors.white, size: 38),
              const SizedBox(height: 16),
              const Text('Buat Laporan Kegiatan Baru', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Catat aktivitas lapangan hari ini', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
              const SizedBox(height: 24),
              Center(
                child: InkWell(
                  onTap: () => Get.snackbar('Info', 'Form laporan akan segera tersedia'),
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Mulai Laporan', style: TextStyle(color: Color(0xFF1E2154), fontWeight: FontWeight.w700, fontSize: 14)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, color: Color(0xFF1E2154), size: 18),
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

  // ✅ Dibungkus Obx — otomatis rebuild saat countPending/Proses/Selesai berubah
  Widget _buildStatsSection() {
    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Kerja',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1F36))),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _buildStatCard(
                      iconEmoji: 'NEW',
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF3B82F6),
                      // ✅ Ambil dari controller, bukan variabel lokal
                      number: _dashboardCtrl.countPending.value.toString(),
                      label: 'KASUS BARU',
                      isTextIcon: true)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard(
                      icon: Icons.sync_rounded,
                      iconBg: const Color(0xFFFFF7ED),
                      iconColor: const Color(0xFFF97316),
                      number: _dashboardCtrl.countProses.value.toString(),
                      label: 'DALAM\nPROSES')),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard(
                      icon: Icons.check_circle_outline_rounded,
                      iconBg: const Color(0xFFECFDF5),
                      iconColor: const Color(0xFF10B981),
                      number: _dashboardCtrl.countSelesai.value.toString(),
                      label: 'SELESAI')),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildStatCard(
      {IconData? icon, String? iconEmoji, bool isTextIcon = false,
        required Color iconBg, required Color iconColor,
        required String number, required String label}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Center(child: isTextIcon
                ? Text(iconEmoji!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: iconColor))
                : Icon(icon, color: iconColor, size: 22)),
          ),
          const SizedBox(height: 10),
          Text(number, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          SizedBox(height: 32, child: Center(child: Text(label, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B), height: 1.2)))),
        ],
      ),
    );
  }

  // ✅ Dibungkus Obx — otomatis rebuild saat recentActivities berubah
// ✅ FUNGSI LENGKAP: UI AKTIVITAS TERBARU (FIX MAPPING DATA)
  Widget _buildRecentActivitySection() {
    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Aktivitas Terbaru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1F36))),
              TextButton(
                onPressed: () {
                  if (Get.isRegistered<MainDashboardAdminController>())
                    Get.find<MainDashboardAdminController>().changeTab(1);
                },
                child: const Text('Lihat Semua', style: TextStyle(color: Color(0xFF1E2154), fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 4),

          if (_dashboardCtrl.isLoadingData.value)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else if (_dashboardCtrl.recentActivities.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Belum ada aktivitas terbaru", style: TextStyle(color: Colors.grey))))
          else
            ..._dashboardCtrl.recentActivities.map((act) {
              // Parsing waktu
              DateTime dt = DateTime.parse(act['created_at']).toLocal();
              String timeStr = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

              // Ambil Judul (Kategori Masalah)
              String judulKasus = (act['pengaduan'] != null)
                  ? act['pengaduan']['kategori_masalah']
                  : 'Kasus Tanpa Judul';

              // Ambil Nama Paralegal (Uploader)
              // Ambil Nama Paralegal lewat pengaduan
              String namaParalegal = (act['pengaduan'] != null &&
                  act['pengaduan']['paralegal'] != null)
                  ? act['pengaduan']['paralegal']['nama_posbankum']
                  : 'Paralegal';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildHistoryCard(
                  icon: Icons.update_rounded,
                  title: judulKasus, // ✅ Nama Kasusnya
                  subtitle: namaParalegal, // ✅ Nama Paralegal yang update
                  badgeText: 'UPDATE',
                  badgeColor: const Color(0xFF3B82F6),
                  badgeBg: const Color(0xFFEFF6FF),
                  timeText: timeStr,
                ),
              );
            }).toList(),
        ],
      ),
    ));
  }

  Widget _buildHistoryCard({required IconData icon, required String title, required String subtitle, required String badgeText, required Color badgeColor, required Color badgeBg, required String timeText}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xFF64748B), size: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)), child: Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w800))),
              const SizedBox(height: 8),
              Text(timeText, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}