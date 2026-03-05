import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_pengaduan_controller.dart';

class RiwayatPengaduanView extends GetView<RiwayatPengaduanController> {
  const RiwayatPengaduanView({super.key});

  @override
  Widget build(BuildContext context) {
    // --- DEFINISI WARNA ---
    const Color darkBlueColor = Color(0xFF2A2E5E);
    const Color whiteBgColor = Color(0xFFF2F4FB);

    return Scaffold(
      backgroundColor: darkBlueColor,
      body: Column(
        children: [
          // ============================================================
          // 1. HEADER AREA
          // ============================================================
          Stack(
            children: [
              // A. Penambal Putih (Patch)
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(width: 50, height: 50, color: whiteBgColor),
              ),

              // B. Container Header Biru
              Container(
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: darkBlueColor,
                  // Header rounded 28 di kiri bawah
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.zero,
                  ),
                ),
                child: Stack(
                  children: [
                    // --- Gambar Aset ---
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

                    // --- Konten Header ---
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
                              'Riwayat Pengaduan',
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
          ),

          // ============================================================
          // 2. BODY AREA
          // ============================================================
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: whiteBgColor,
                // Body rounded 28 di kanan atas
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(28),
                  topLeft: Radius.zero,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSearchBar(),
                  ),

                  const SizedBox(height: 16),

                  // --- TAB FILTER ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildTabFilter(),
                  ),

                  const SizedBox(height: 16),

                  // Label Jumlah Data
                  Obx(() => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Menampilkan ${controller.filteredItems.length} data',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  )),

                  const SizedBox(height: 8),

                  // List Data
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.filteredItems.isEmpty) {
                        return _buildEmptyState();
                      }
                      return RefreshIndicator(
                        onRefresh: controller.fetchRiwayatPengaduan,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                          itemCount: controller.filteredItems.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _buildCardItem(controller.filteredItems[index]);
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
    );
  }

  // ========================================================================
  // WIDGET PENDUKUNG
  // ========================================================================

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (val) => controller.searchQuery.value = val,
        decoration: InputDecoration(
          hintText: 'Cari Tiket ID atau Judul...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  // ─── FILTER TAB (Radius 10) ───
  Widget _buildTabFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTabButton(
          text: 'Semua',
          tab: StatusPengaduan.semua,
          activeColor: const Color(0xFF2A2E5E),
        ),
        const SizedBox(width: 10),
        _buildTabButton(
          text: 'Proses',
          tab: StatusPengaduan.dalamProses,
          activeColor: Colors.blue.shade600,
        ),
        const SizedBox(width: 10),
        _buildTabButton(
          text: 'Selesai',
          tab: StatusPengaduan.selesai,
          activeColor: Colors.green.shade600,
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required String text, 
    required StatusPengaduan tab, 
    required Color activeColor
  }) {
    return Obx(() {
      final bool isActive = controller.selectedTab.value == tab;
      return Expanded(
        child: GestureDetector(
          onTap: () => controller.changeTab(tab),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? activeColor : Colors.white,
              // Radius 10 sesuai request
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                topLeft: Radius.circular(4),  
                bottomRight: Radius.circular(4),
              ),
              boxShadow: isActive 
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
              border: isActive 
                ? null 
                : Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCardItem(PengaduanItem item) {
    // ✅ BUNGKUS DENGAN GESTURE DETECTOR
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman Detail Kasus
        // Nanti kalau pakai data database asli, kita bisa lempar datanya ke sini:
        // Get.toNamed('/detail-kasus', arguments: item);
        Get.toNamed('/detail-kasus');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2A2E5E).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4FB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.gavel_rounded, color: Color(0xFF2A2E5E), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.judul,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2A2E5E),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_month_outlined, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              item.tanggal,
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(item.status),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey[200]),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        item.idTiket,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          fontFamily: 'Monospace',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 46,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2A2E5E),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: const Icon(Icons.chevron_right, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label = status;

    switch (status.toLowerCase()) {
      case 'selesai':
        bg = const Color(0xFFE8F5E9);
        text = const Color(0xFF2E7D32);
        break;
      case 'proses':
      case 'diproses':
        bg = const Color(0xFFE3F2FD);
        text = const Color(0xFF1565C0);
        break;
      case 'ditolak':
        bg = Colors.red.shade50;
        text = Colors.red.shade700;
        break;
      default:
        bg = const Color(0xFFFFF3E0);
        text = const Color(0xFFEF6C00);
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_outlined, size: 40, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada pengaduan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}