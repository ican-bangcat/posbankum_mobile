import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_dashboard_controller.dart';
import '../../pengaduan/controllers/daftar_pengaduan_controller.dart';
import '../../pengaduan/views/daftar_pengaduan_view.dart';
import '../../auth/views/home_masyarakat_screen.dart';
import '../../profile/views/profile_view.dart';
import '../../notifikasi_masyarakat/views/notifikasi_masyarakat_view.dart';
import '../../notifikasi_masyarakat/controllers/notifikasi_masyarakat_controller.dart';
import '../../daftar_chat_masyarakat/controllers/daftar_chat_masyarakat_controller.dart';
import '../../daftar_chat_masyarakat/views/daftar_chat_masyarakat_view.dart';
import '../../../app/routes/app_routes.dart';

class MainDashboardView extends GetView<MainDashboardController> {
  const MainDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const NotifikasiMasyarakatView(),
      const DaftarPengaduanView(),
      const HomeMasyarakatScreen(),
      const DaftarChatMasyarakatView(),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4FB),
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

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = controller.selectedIndex.value == index;
    final color = isActive ? const Color(0xFF2A2E5E) : const Color(0xFFA8A8A8);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          if (index == 1) {
            // If the local cache indicates the profile is already complete, transition instantly!
            if (controller.isAllComplete) {
              controller.changeTab(index);
              // Silently refresh profile completeness in the background to ensure it stays in sync
              controller.checkProfileCompleteness();
              return;
            }

            if (controller.isProfileChecking.value) return; // Prevent double-clicks / spamming

            // Show a simple non-dismissible loading overlay
            Get.dialog(
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              barrierDismissible: false,
            );

            try {
              await controller.checkProfileCompleteness();
            } finally {
              if (Get.isDialogOpen == true) {
                Get.back(); // Dismiss loading dialog
              }
            }

            if (!controller.isAllComplete) {
              if (Get.isBottomSheetOpen != true) {
                _showIncompleteProfilePopup();
              }
              return;
            }
          }
          controller.changeTab(index);
        },
        child: SizedBox(
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
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
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 26),
                  const SizedBox(height: 4),
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

  void _showIncompleteProfilePopup() {
    Get.bottomSheet(
      Builder(
        builder: (sheetContext) {
          final double sheetBottomPadding = MediaQuery.of(sheetContext).padding.bottom;
          return Container(
            height: Get.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Stack(
              children: [
                // Header Gradient Section
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF2A2E5E), Color(0xFF4B53A6)],
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Icon Profile with Warning
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 50),
                          ),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Color(0xFFE2C842), shape: BoxShape.circle),
                            child: const Icon(Icons.priority_high, color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Profil Belum Lengkap!',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Untuk membuat pengaduan, Anda perlu melengkapi data diri terlebih dahulu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress Bar Indicator
                Positioned(
                  top: 235,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        _buildStepBar(controller.isNamaComplete.value),
                        const SizedBox(width: 8),
                        _buildStepBar(controller.isNikComplete.value),
                        const SizedBox(width: 8),
                        _buildStepBar(controller.isTeleponComplete.value),
                        const SizedBox(width: 8),
                        _buildStepBar(controller.isAlamatComplete.value),
                      ],
                    ),
                  ),
                ),

                // Close Button
                Positioned(
                  top: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),

                // Content Section
                Positioned.fill(
                  top: 260,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildStatusItem(
                            icon: Icons.person_outline,
                            label: 'Nama Lengkap',
                            isComplete: controller.isNamaComplete.value,
                          ),
                          const SizedBox(height: 12),
                          _buildStatusItem(
                            icon: Icons.badge_outlined,
                            label: 'NIK (16 Digit)',
                            isComplete: controller.isNikComplete.value,
                          ),
                          const SizedBox(height: 12),
                          _buildStatusItem(
                            icon: Icons.phone_outlined,
                            label: 'No. Telepon',
                            isComplete: controller.isTeleponComplete.value,
                          ),
                          const SizedBox(height: 12),
                          _buildStatusItem(
                            icon: Icons.location_on_outlined,
                            label: 'Alamat & Wilayah',
                            isComplete: controller.isAlamatComplete.value,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              Get.toNamed(AppRoutes.EDIT_PROFILE);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A2E5E),
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit_note, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Lengkapi Profil Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text(
                              'Lewati, isi nanti',
                              style: TextStyle(
                                color: Color(0xFF64748B), // Slate 600 - lebih kontras dan mudah dibaca
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                decoration: TextDecoration.underline, // Tambahkan underline agar lebih jelas bahwa ini tombol
                              ),
                            ),
                          ),
                          SizedBox(height: 20 + sheetBottomPadding),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  Widget _buildStepBar(bool isComplete) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: isComplete ? const Color(0xFF22C55E) : const Color(0xFFE2C842),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required bool isComplete,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isComplete ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete ? const Color(0xFF22C55E).withOpacity(0.1) : const Color(0xFFE2C842).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isComplete ? const Color(0xFF22C55E).withOpacity(0.1) : const Color(0xFFE2C842).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: isComplete ? const Color(0xFF22C55E) : const Color(0xFFE2C842)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isComplete ? const Color(0xFF166534) : const Color(0xFF92400E),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isComplete ? const Color(0xFF22C55E).withOpacity(0.1) : const Color(0xFFE2C842).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  isComplete ? 'Lengkap' : 'Belum diisi',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isComplete ? const Color(0xFF22C55E) : const Color(0xFFE2C842),
                  ),
                ),
                if (isComplete) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.check_circle, size: 14, color: Color(0xFF22C55E)),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
