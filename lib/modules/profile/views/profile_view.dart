import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../app/routes/app_routes.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    
    // Hitung tinggi background biru agar presisi di berbagai ukuran layar
    final double paddingTop = MediaQuery.of(context).padding.top;
    final double headerHeight = paddingTop + 140; // 140px dari bawah status bar

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5), // Latar dasar abu-abu
      body: Stack(
        children: [
          // 1. Kotak Biru penambal (patch) di sebelah kanan agar ujung abu-abu bisa melengkung
          Positioned(
            top: headerHeight - 20, // Sedikit overlap ke atas agar tidak ada garis putih
            right: 0,
            width: 100,
            height: 100,
            child: Container(color: const Color(0xFF2A2E5E)),
          ),

          // 2. Latar Belakang Abu-abu untuk bagian body yang menutupi penambal biru
          Positioned(
            top: headerHeight,
            left: 0, right: 0, bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F5),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40), // Kanan atas abu-abu dibikin rounded!
                  // Kiri atas dibiarkan tajam (square) karena akan diisi oleh lengkungan biru
                ),
              ),
            ),
          ),

          // 3. Background Header (Biru)
          Positioned(
            top: 0, left: 0, right: 0, height: headerHeight,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2A2E5E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40), // Bagian biru kiri bawah rounded
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                ),
                child: Opacity(
                  opacity: 0.15,
                  child: Image.asset(
                    'assets/images/icons/building_illustration.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (c, e, s) => const SizedBox(),
                  ),
                ),
              ),
            ),
          ),
          
          // 4. Foreground Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Jarak atas agar Summary Card posisinya numpang tepat di perbatasan
                const SizedBox(height: 40), 
                
                // Summary Card (Tetap / Fixed posisinya, tidak ikut di-scroll)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSummaryCard(),
                ),
                
                const SizedBox(height: 20),

                // Area yang bisa di-scroll (Data Diri, dsb)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    child: Column(
                      children: [
                        _buildDataDiriCard(),
                        const SizedBox(height: 20),
                        _buildRiwayatCard(),
                        const SizedBox(height: 30),
                        _buildLogoutButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A61A8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Obx(() {
                      bool hasAvatar = controller.avatarUrl.value.isNotEmpty;
                      if (hasAvatar) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(controller.avatarUrl.value, fit: BoxFit.cover),
                        );
                      }
                      String initials = controller.namaLengkap.value.isNotEmpty 
                          ? controller.namaLengkap.value[0].toUpperCase() 
                          : 'S';
                      return Center(
                        child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      );
                    }),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 0, right: 0),
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Name & Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      controller.namaLengkap.value.isEmpty ? 'Suryanto Hadikusuma' : controller.namaLengkap.value,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    )),
                    const SizedBox(height: 4),
                    const Text('Warga Terverifikasi', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1),
          const SizedBox(height: 16),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('3', 'Pengaduan'),
              _buildStatItem('2', 'Diproses'),
              _buildStatItem('1', 'Selesai'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A2E5E))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildDataDiriCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Data Diri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              InkWell(
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(Icons.edit_document, size: 14, color: Color(0xFF2A2E5E)),
                    SizedBox(width: 4),
                    Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2A2E5E))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() => _buildDataItem(Icons.person_outline, 'Nama Lengkap', controller.namaLengkap.value.isEmpty ? '-' : controller.namaLengkap.value)),
          const Divider(color: Color(0xFFF1F5F9)),
          Obx(() => _buildDataItem(Icons.shield_outlined, 'NIK', controller.nik.value.isEmpty ? '-' : controller.nik.value)),
          const Divider(color: Color(0xFFF1F5F9)),
          Obx(() => _buildDataItem(Icons.phone_outlined, 'No. Telepon', controller.noHp.value.isEmpty ? '-' : controller.noHp.value)),
          const Divider(color: Color(0xFFF1F5F9)),
          Obx(() => _buildDataItem(Icons.business_outlined, 'Kelurahan', controller.kelurahanInfo.value.isEmpty ? '-' : controller.kelurahanInfo.value)),
          const Divider(color: Color(0xFFF1F5F9)),
          Obx(() => _buildDataItem(Icons.location_on_outlined, 'Alamat', controller.alamat.value.isEmpty ? '-' : controller.alamat.value)),
        ],
      ),
    );
  }

  Widget _buildDataItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF64748B), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Riwayat Pengaduan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4A61A8))),
            ],
          ),
          const SizedBox(height: 20),
          _buildRiwayatItem('Sengketa Tanah Waris', '#K-2026-8238  •  24 Okt 2023', 'Diproses', Colors.orange),
          const Divider(color: Color(0xFFF1F5F9)),
          _buildRiwayatItem('Permasalahan Batas Pagar', '#K-2026-8102  •  12 Sep 2023', 'Selesai', Colors.green),
        ],
      ),
    );
  }

  Widget _buildRiwayatItem(String title, String subtitle, String status, MaterialColor statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.description_outlined, color: Color(0xFF64748B), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.shade200),
            ),
            child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)], // Soft premium red gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => controller.logout(),
          highlightColor: const Color(0xFFFCA5A5).withOpacity(0.2),
          splashColor: const Color(0xFFF87171).withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  ),
                  child: const Icon(Icons.power_settings_new_rounded, size: 20, color: Color(0xFFEF4444)),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Keluar dari Akun',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFDC2626),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}