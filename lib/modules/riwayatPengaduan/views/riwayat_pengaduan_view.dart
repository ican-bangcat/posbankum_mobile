import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_pengaduan_controller.dart';
import '../../detail_kasus/controllers/detail_kasus_controller.dart'; // ✅ Import Controller Detail

class RiwayatPengaduanView extends GetView<RiwayatPengaduanController> {
  const RiwayatPengaduanView({super.key});

  @override
  Widget build(BuildContext context) {
    // --- DEFINISI WARNA (DARI KODE ASLI) ---
    const Color darkBlueColor = Color(0xFF2A2E5E);
    const Color whiteBgColor = Color(0xFFF2F4FB);

    return Scaffold(
      backgroundColor: darkBlueColor,

      body: Column(
        children: [
          // ============================================================
          // 1. HEADER AREA (KODE ASLI - TIDAK DIUBAH)
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
                // Body rounded 28 di kanan atas (KODE ASLI)
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(28),
                  topLeft: Radius.zero,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Search Bar (KODE ASLI)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSearchBar(),
                  ),

                  const SizedBox(height: 16),

                  // --- TAB FILTER (KODE ASLI - TIDAK DIUBAH) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildTabFilter(),
                  ),

                  const SizedBox(height: 16),

                  // Label Jumlah Data (KODE ASLI)
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
                            // MENGGUNAKAN DESAIN KARTU PREMIUM
                            return _buildCardItemMenarik(controller.filteredItems[index]);
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
  // WIDGET PENDUKUNG (SEARCH BAR & TABS ASLI)
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

  // ─── FILTER TAB (Radius 10) - ASLI ───
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
              // Radius asli
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

  // ========================================================================
  // DESAIN KARTU BARU YANG LEBIH MENARIK (PREMIUM FEEL)
  // ========================================================================

  Widget _buildCardItemMenarik(PengaduanItem item) {
    const Color textPrimary = Color(0xFF0F172A);
    const Color textSecondary = Color(0xFF64748B);
    final Color statusColor = _getStatusColor(item.status);

    return GestureDetector(
      onTap: () {
        // ✅ 1. Bersihkan controller detail kasus agar data tidak nyangkut
        Get.delete<DetailKasusController>();
        // ✅ 2. Bawa ID asli dari database ke halaman detail
        Get.toNamed('/detail-kasus', arguments: item.idTiket);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        // Menggunakan ClipRRect untuk memotong border kiri agar melengkung rapi
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: statusColor, // Warna garis kiri menyesuaikan status
                  width: 5,
                ),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BARIS 1: ID Tiket & Status Badge ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.confirmation_num_rounded, size: 14, color: textSecondary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.idTiket,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textSecondary,
                            fontFamily: 'Monospace',
                          ),
                        ),
                      ],
                    ),
                    _buildStatusBadgeMenarik(item.status),
                  ],
                ),

                const SizedBox(height: 14),

                // --- BARIS 2: Judul Pengaduan ---
                Text(
                  item.judul,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      height: 1.3
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 14),

                // --- BARIS 3: Info Meta (Tanggal & Kategori) ---
                Row(
                  children: [
                    _buildIconText(Icons.calendar_month_rounded, item.tanggal),
                    const SizedBox(width: 16),
                    // Kategori sementara statis. Nanti bisa diganti: item.kategori ?? 'Hukum Perdata'
                    _buildIconText(Icons.folder_open_rounded, 'Hukum Perdata'),
                  ],
                ),

                const SizedBox(height: 14),
                _buildDashedLine(),
                const SizedBox(height: 14),

                // --- BARIS 4: Aksi (Lihat Detail) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ketuk untuk melihat detail',
                      style: TextStyle(fontSize: 12, color: Colors.black38, fontStyle: FontStyle.italic),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF), // Biru sangat muda
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Text(
                            'Detail',
                            style: TextStyle(color: Color(0xFF2563EB), fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF2563EB)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Pembantu untuk Ikon + Teks (Tanggal/Kategori)
  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Fungsi Mendapatkan Warna Berdasarkan Status (Untuk Garis Kiri Aksent)
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai': return const Color(0xFF10B981); // Emerald Green
      case 'proses':
      case 'diproses': return const Color(0xFF3B82F6); // Blue
      case 'ditolak': return const Color(0xFFEF4444); // Red
      default: return const Color(0xFFF59E0B); // Amber/Yellow
    }
  }

  // Desain Status Badge (Bentuk Pill)
  Widget _buildStatusBadgeMenarik(String status) {
    Color bg;
    Color text;
    String label = status;

    switch (status.toLowerCase()) {
      case 'selesai':
        bg = const Color(0xFFD1FAE5);
        text = const Color(0xFF059669);
        break;
      case 'proses':
      case 'diproses':
        bg = const Color(0xFFDBEAFE);
        text = const Color(0xFF2563EB);
        break;
      case 'ditolak':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFDC2626);
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
    );
  }

  // Fungsi Pembuat Garis Putus-putus
  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 6.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFE2E8F0)), // Abu-abu terang
              ),
            );
          }),
        );
      },
    );
  }

  // Empty State ASLI
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