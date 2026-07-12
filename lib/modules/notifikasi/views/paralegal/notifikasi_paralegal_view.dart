import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notifikasi_paralegal_controller.dart';
import '../../models/notifikasi_model.dart';

class NotifikasiParalegalView extends GetView<NotifikasiParalegalController> {
  const NotifikasiParalegalView({super.key});

  static const Color darkBlueColor = Color(0xFF2A2E5E);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NotifikasiParalegalController>()) {
      Get.put(NotifikasiParalegalController());
    }

    return Scaffold(
      backgroundColor: darkBlueColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              children: [
                // ── HEADER (Dengan Tombol Kembali) ──
                _buildHeader(),
      
                // ── KONTEN UTAMA ──
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F4FB),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(28),
                        topLeft: Radius.zero,
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        
                        // Filter Chips & Mark All Read
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Obx(() => Row(
                                        children: [
                                          _buildFilterChip('Semua', 0),
                                          const SizedBox(width: 8),
                                          _buildFilterChip('Belum Dibaca', 1),
                                          const SizedBox(width: 8),
                                          _buildFilterChip('Sudah Dibaca', 2),
                                        ],
                                      )),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.done_all_rounded, color: darkBlueColor),
                                tooltip: 'Tandai semua dibaca',
                                onPressed: () => controller.markAllAsRead(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
      
                        // List Notifikasi
                        Expanded(
                          child: Obx(() {
                            if (controller.isLoading.value && controller.allNotifications.isEmpty) {
                              return const Center(child: CircularProgressIndicator());
                            }
      
                            final items = controller.filteredNotifications;
      
                            if (items.isEmpty) {
                              return RefreshIndicator(
                                onRefresh: () => controller.fetchNotifications(),
                                color: darkBlueColor,
                                child: ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: const [
                                    SizedBox(height: 100),
                                    Center(
                                      child: Text(
                                        "Tidak ada notifikasi",
                                        style: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
      
                            return RefreshIndicator(
                              onRefresh: () => controller.fetchNotifications(),
                              color: darkBlueColor,
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildNotificationCard(item),
                                  );
                                },
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    const Color whiteBgColor = Color(0xFFF2F4FB);
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(width: 50, height: 50, color: whiteBgColor),
        ),
        Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            color: darkBlueColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.zero,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -10,
                right: -5,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    'assets/images/icons/building_illustration3.png',
                    width: 300,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.location_city, size: 200, color: Colors.white10),
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
      ],
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = controller.selectedFilter.value == index;

    return GestureDetector(
      onTap: () => controller.changeFilter(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? darkBlueColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? darkBlueColor : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotifikasiItem item) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (item.kategori.toLowerCase()) {
      case 'pengaduan':
        icon = Icons.gavel_rounded;
        iconColor = const Color(0xFF3B82F6);
        iconBg = const Color(0xFFEFF6FF);
        break;
      case 'kegiatan':
        icon = Icons.event_note_rounded;
        iconColor = const Color(0xFF10B981);
        iconBg = const Color(0xFFECFDF5);
        break;
      case 'dokumen':
        icon = Icons.folder_copy_outlined;
        iconColor = const Color(0xFFF59E0B);
        iconBg = const Color(0xFFFEF3C7);
        break;
      default:
        icon = Icons.info_outline_rounded;
        iconColor = const Color(0xFF6B7280);
        iconBg = const Color(0xFFF3F4F6);
    }

    return GestureDetector(
      onTap: () => controller.markAsRead(item),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead ? const Color(0xFFE2E8F0) : const Color(0xFFC7D2FE),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Badge
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                if (!item.isRead)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4F46E5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            
            // Content
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
                          item.judul,
                          style: TextStyle(
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                            fontSize: 14,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.formattedTime,
                        style: const TextStyle(
                          fontSize: 11,
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.pesan,
                    style: TextStyle(
                      fontSize: 13,
                      color: item.isRead ? textSecondary : textPrimary.withOpacity(0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
