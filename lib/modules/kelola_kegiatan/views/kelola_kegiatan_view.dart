import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/kelola_kegiatan_controller.dart';
import '../../../app/routes/app_routes.dart';

class KelolaKegiatanView extends GetView<KelolaKegiatanController> {
  const KelolaKegiatanView({super.key});

  static const Color darkBlueColor = Color(0xFF2A2E5E);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    Get.put(KelolaKegiatanController());

    return Scaffold(
      backgroundColor: darkBlueColor,
      body: Column(
        children: [
          // ── HEADER (Tanpa Tombol Back) ──
          _buildHeader(),

          // ── KONTEN BAWAH ──
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.only(topRight: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // ── SEARCH BAR & DATE FILTER ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(child: _buildSearchBar()),
                        const SizedBox(width: 12),
                        _buildDateFilterButton(context),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── GRADIENT BUTTON ──
                          _buildGradientButton(),
                          const SizedBox(height: 32),

                          // ── HEADER LIST ──
                          Obx(() {
                            String label = 'DAFTAR KEGIATAN';
                            if (controller.selectedFilterDate.value != null) {
                              label = 'KEGIATAN: ${DateFormat('MMMM yyyy', 'id_ID').format(controller.selectedFilterDate.value!).toUpperCase()}';
                            }
                            return Text(
                              label,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 1.0),
                            );
                          }),
                          const SizedBox(height: 16),

                          // ── LIST KARTU KEGIATAN ──
                          Obx(() {
                            if (controller.isLoading.value) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final items = controller.filteredKegiatan;

                            if (items.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: Text("Tidak ada kegiatan yang ditemukan", style: TextStyle(color: Colors.grey)),
                                ),
                              );
                            }

                            return Column(
                              children: items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: _buildKegiatanCard(item),
                              )).toList(),
                            );
                          }),
                          const SizedBox(height: 100),
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

  // ═════════════════════════════════════════════════════════════════
  // WIDGET COMPONENTS
  // ═════════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return Stack(
      children: [
        const Positioned(bottom: 0, left: 0, child: SizedBox(width: 50, height: 50, child: DecoratedBox(decoration: BoxDecoration(color: bgLight)))),
        Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(color: darkBlueColor, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28))),
          child: Stack(
            children: [
              Positioned(
                top: -10, right: -5,
                child: Opacity(opacity: 0.8, child: Image.asset('assets/images/icons/building_illustration3.png', width: 300, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const SizedBox())),
              ),
              const SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 20, 20, 30),
                  child: Text('Kelola Kegiatan', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        onChanged: (val) => controller.searchQuery.value = val,
        decoration: const InputDecoration(
          hintText: 'Cari kegiatan...',
          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  // ✅ TOMBOL FILTER TANGGAL DI SAMPING SEARCH
  Widget _buildDateFilterButton(BuildContext context) {
    return Obx(() {
      final isFiltered = controller.selectedFilterDate.value != null;
      return GestureDetector(
        onTap: () {
          if (isFiltered) {
            controller.clearFilterDate(); // Klik lagi untuk reset
          } else {
            controller.pickFilterDate(context); // Buka kalender
          }
        },
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: isFiltered ? darkBlueColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isFiltered ? darkBlueColor : const Color(0xFFE2E8F0)),
          ),
          child: Icon(
            isFiltered ? Icons.event_busy : Icons.calendar_month_outlined,
            color: isFiltered ? Colors.white : textSecondary,
          ),
        ),
      );
    });
  }

  Widget _buildGradientButton() {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.TAMBAH_KEGIATAN);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF3B418E), darkBlueColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: darkBlueColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Mulai buat Laporan kegiatan',
                style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 14),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: textPrimary, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      case 'menunggu':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildKegiatanCard(KegiatanItem item) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                item.imageUrl ?? '',
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                ),
              ),

              Positioned(
                top: 16, left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: _getStatusColor(item.status),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(
                      item.status.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.judul, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 16, color: textSecondary),
                    const SizedBox(width: 8),
                    Text(item.tanggal, style: const TextStyle(fontSize: 13, color: textSecondary, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: textSecondary),
                    const SizedBox(width: 8),
                    Text(item.lokasi, style: const TextStyle(fontSize: 13, color: textSecondary, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 20),

                // Footer Card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ Chip Jumlah Anggota Dinamis (Menggantikan Avatar)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people_alt_outlined, size: 14, color: textSecondary),
                          const SizedBox(width: 6),
                          Text(
                              '${item.jumlahAnggota} Terlibat',
                              style: const TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600)
                          ),
                        ],
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.DETAIL_KEGIATAN, arguments: item.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBlueColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Lihat Detail', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}