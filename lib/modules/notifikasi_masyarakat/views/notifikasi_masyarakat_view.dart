import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notifikasi_masyarakat_controller.dart';

class NotifikasiMasyarakatView extends GetView<NotifikasiMasyarakatController> {
  const NotifikasiMasyarakatView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkBlueColor = Color(0xFF2A2E5E);
    const Color whiteBgColor = Color(0xFFF2F4FB);

    return Scaffold(
      backgroundColor: darkBlueColor,
      body: Column(
        children: [
          // ── HEADER AREA ──
          Container(
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: darkBlueColor,
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -10,
                  right: -5,
                  child: Opacity(
                    opacity: 0.15,
                    child: Image.asset(
                      'assets/images/icons/building_illustration3.png',
                      width: 300,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Notifikasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── BODY AREA ──
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: whiteBgColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Obx(() => Row(
                          children: [
                            _buildFilterChip('Semua', 0),
                            const SizedBox(width: 12),
                            _buildFilterChip('Belum Dibaca', 1),
                            const SizedBox(width: 12),
                            _buildFilterChip('Sudah Dibaca', 2),
                          ],
                        )),
                  ),
                  const SizedBox(height: 24),

                  // List Notifikasi
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TERBARU',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildNotificationCard(
                            title: 'Update Kasus Sengketa Tanah',
                            time: '2m yang lalu',
                            description: 'Status kasus Anda telah diperbarui menjadi Mediasi. Silakan cek detail jadwal.',
                            icon: Icons.gavel_rounded,
                            iconBgColor: const Color(0xFFC5D0E6),
                            iconColor: darkBlueColor,
                            isUnread: true,
                          ),
                          const SizedBox(height: 12),
                          _buildNotificationCard(
                            title: 'Pesan Baru: POSBAKUM',
                            time: '15m yang lalu',
                            description: 'Kelurahan Tuah Madani mengirimkan berkas persyaratan tambahan untuk verifikasi.',
                            icon: Icons.chat_bubble_outline_rounded,
                            iconBgColor: const Color(0xFFD1F4E0),
                            iconColor: const Color(0xFF198754),
                            isUnread: true,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'MINGGU INI',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildNotificationCard(
                            title: 'Pengingat: Penyuluhan Hukum',
                            time: 'Kemarin',
                            description: 'Jangan lupa: Penyuluhan Hukum di Desa Sukamaju besok jam 09:00 WIB.',
                            icon: Icons.calendar_month_outlined,
                            iconBgColor: const Color(0xFFFFE0CC),
                            iconColor: const Color(0xFFE65C00),
                            isUnread: false,
                            isWhiteCard: true,
                          ),
                          const SizedBox(height: 12),
                          _buildNotificationCard(
                            title: 'Verifikasi Berkas Selesai',
                            time: '2 hari lalu',
                            description: 'Dokumen identitas Anda telah diverifikasi oleh tim POSBAKUM Pusat.',
                            icon: Icons.description_outlined,
                            iconBgColor: const Color(0xFFEBEBEB),
                            iconColor: const Color(0xFF555555),
                            isUnread: false,
                            isWhiteCard: true,
                          ),
                          const SizedBox(height: 12),
                          _buildNotificationCard(
                            title: 'Login Perangkat Baru',
                            time: 'Selasa',
                            description: 'Seseorang baru saja login ke akun Anda melalui browser Chrome di Windows.',
                            icon: Icons.security_outlined,
                            iconBgColor: const Color(0xFFFFD6D6),
                            iconColor: const Color(0xFFD32F2F),
                            isUnread: false,
                            isWhiteCard: true,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    const Color darkBlueColor = Color(0xFF2A2E5E);
    final isSelected = controller.selectedFilter.value == index;

    return GestureDetector(
      onTap: () => controller.changeFilter(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? darkBlueColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? darkBlueColor : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : darkBlueColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String time,
    required String description,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required bool isUnread,
    bool isWhiteCard = false,
  }) {
    const Color darkBlueColor = Color(0xFF2A2E5E);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWhiteCard ? Colors.white : const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              if (isUnread)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: darkBlueColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
