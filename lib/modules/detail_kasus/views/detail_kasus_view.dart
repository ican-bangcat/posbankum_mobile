import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_kasus_controller.dart';

class DetailKasusView extends GetView<DetailKasusController> {
  const DetailKasusView({super.key});

  // ── WARNA UTAMA (konsisten dengan referensi) ──
  static const Color darkBlueColor = Color(0xFF2A2E5E);
  static const Color whiteBgColor = Color(0xFFF2F4FB);

  // ── WARNA STATUS ──
  static const Color pendingBorder = Color(0xFFEF9A00);
  static const Color pendingBg = Color(0xFFFFF3E0);
  static const Color pendingText = Color(0xFFEF6C00);

  static const Color diprosesBorder = Color(0xFF1565C0);
  static const Color diprosesBg = Color(0xFFE3F2FD);
  static const Color diprosesText = Color(0xFF1565C0);

  static const Color selesaiBorder = Color(0xFF2E7D32);
  static const Color selesaiBg = Color(0xFFE8F5E9);
  static const Color selesaiText = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlueColor,
      body: Column(
        children: [
          // ══════════════════════════════════════════════════════════
          // 1. HEADER AREA — SAMA PERSIS dengan referensi
          // ══════════════════════════════════════════════════════════
          _buildHeader(),

          // ══════════════════════════════════════════════════════════
          // 2. BODY AREA — SAMA PERSIS dengan referensi
          // ══════════════════════════════════════════════════════════
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: whiteBgColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(28),
                  topLeft: Radius.zero,
                ),
              ),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final kasus = controller.kasus.value;
                if (kasus == null) {
                  return const Center(child: Text('Data tidak ditemukan'));
                }

                return Column(
                  children: [
                    // ── Scrollable content ──
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1) Card Info Utama
                            _buildInfoCard(kasus),
                            const SizedBox(height: 24),

                            // 2) Box Kronologi
                            _buildKronologiBox(kasus),
                            const SizedBox(height: 24),

                            // 3) Timeline Proses
                            _buildTimelineSection(kasus),
                            const SizedBox(height: 24),

                            // 4) Catatan Paralegal (kondisional)
                            if (kasus.catatanParalegal != null &&
                                kasus.catatanParalegal!.isNotEmpty)
                              _buildCatatanParalegalBox(kasus),
                          ],
                        ),
                      ),
                    ),

                    // 5) Tombol "Ambil Kasus" — HANYA jika Pending
                    if (kasus.status.toLowerCase() == 'pending')
                      _buildAmbilKasusButton(),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  HEADER  — replika persis dari referensi
  // ════════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Stack(
      children: [
        // A. Penambal putih (patch)
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
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.zero,
            ),
          ),
          child: Stack(
            children: [
              // ── Gambar Gedung ──
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
                    const Icon(Icons.location_city,
                        size: 200, color: Colors.white10),
                  ),
                ),
              ),

              // ── Konten Header ──
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
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Detail Kasus',
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

  // ════════════════════════════════════════════════════════════════════
  //  1. CARD INFO UTAMA  — border warna mengikuti status
  // ════════════════════════════════════════════════════════════════════
  Widget _buildInfoCard(DetailKasus kasus) {
    final statusColors = _getStatusColors(kasus.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColors['border']!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColors['border']!.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row: Judul + Badge ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  kasus.judulKasus,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkBlueColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildStatusBadge(kasus.status),
            ],
          ),
          const SizedBox(height: 10),

          // ── ID Kasus ──
          Row(
            children: [
              Icon(Icons.confirmation_number_outlined,
                  size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                'ID: ${kasus.idKasus}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ── Tanggal Dibuat ──
          Row(
            children: [
              Icon(Icons.calendar_month_outlined,
                  size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                'Dibuat: ${kasus.tanggalDibuat}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  2. BOX KRONOLOGI
  // ════════════════════════════════════════════════════════════════════
  Widget _buildKronologiBox(DetailKasus kasus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kronologi Pengaduan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: darkBlueColor,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Text(
            kasus.kronologi,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  3. TIMELINE PROSES  — custom vertical timeline
  // ════════════════════════════════════════════════════════════════════
  Widget _buildTimelineSection(DetailKasus kasus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timeline Proses',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: darkBlueColor,
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(kasus.timeline.length, (index) {
          final item = kasus.timeline[index];
          final isLast = index == kasus.timeline.length - 1;
          return _buildTimelineItem(
            item: item,
            isLast: isLast,
          );
        }),
      ],
    );
  }

  Widget _buildTimelineItem({
    required TimelineItem item,
    required bool isLast,
  }) {
    const double bulletSize = 14;
    const double lineWidth = 2;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Kolom kiri: Bullet + Garis ──
          SizedBox(
            width: 30,
            child: Column(
              children: [
                const SizedBox(height: 3),
                // Bullet
                Container(
                  width: bulletSize,
                  height: bulletSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.isActive ? darkBlueColor : Colors.transparent,
                    border: Border.all(
                      color: item.isActive
                          ? darkBlueColor
                          : Colors.grey.shade400,
                      width: item.isActive ? 0 : 2,
                    ),
                  ),
                ),
                // Garis vertikal
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: lineWidth,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: item.isActive
                          ? darkBlueColor.withOpacity(0.3)
                          : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // ── Kolom kanan: Teks ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                      item.isActive ? FontWeight.w600 : FontWeight.w400,
                      color: item.isActive ? darkBlueColor : Colors.grey[500],
                    ),
                  ),
                  if (item.tanggal != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.tanggal!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  4. BOX CATATAN PARALEGAL
  // ════════════════════════════════════════════════════════════════════
  Widget _buildCatatanParalegalBox(DetailKasus kasus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan Paralegal',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: darkBlueColor,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Tanggal - Penulis ──
              if (kasus.catatanTanggal != null || kasus.catatanPenulis != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    [
                      if (kasus.catatanTanggal != null) kasus.catatanTanggal,
                      if (kasus.catatanPenulis != null) kasus.catatanPenulis,
                    ].join(' - '),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),

              // ── Isi catatan ──
              Text(
                kasus.catatanParalegal!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  5. TOMBOL AMBIL KASUS  — hanya muncul saat Pending
  // ════════════════════════════════════════════════════════════════════
  Widget _buildAmbilKasusButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: whiteBgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => controller.ambilKasus(),
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBlueColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: darkBlueColor.withOpacity(0.4),
        ),
        child: const Text(
          'Ambil Kasus',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  HELPER: Status Badge
  // ════════════════════════════════════════════════════════════════════
  Widget _buildStatusBadge(String status) {
    final colors = _getStatusColors(status);
    String label;

    switch (status.toLowerCase()) {
      case 'selesai':
        label = 'Selesai';
        break;
      case 'diproses':
        label = 'Sedang Diproses';
        break;
      default:
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors['border']!, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors['text'],
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  HELPER: Warna berdasarkan status
  // ════════════════════════════════════════════════════════════════════
  Map<String, Color> _getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return {
          'border': selesaiBorder,
          'bg': selesaiBg,
          'text': selesaiText,
        };
      case 'diproses':
        return {
          'border': diprosesBorder,
          'bg': diprosesBg,
          'text': diprosesText,
        };
      default: // pending
        return {
          'border': pendingBorder,
          'bg': pendingBg,
          'text': pendingText,
        };
    }
  }
}