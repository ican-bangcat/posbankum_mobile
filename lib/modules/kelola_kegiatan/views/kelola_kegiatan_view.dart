import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    // Inisialisasi controller jika belum ada
    Get.put(KelolaKegiatanController());

    return Scaffold(
      backgroundColor: darkBlueColor,
      body: Column(
        children: [
          // ── HEADER ──
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

                  // ── SEARCH BAR ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSearchBar(),
                  ),
                  const SizedBox(height: 20),

                  // ── TAB BAR ──
                  _buildTabBar(),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 20),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── GRADIENT BUTTON (Mulai Buat Laporan) ──
                          _buildGradientButton(),
                          const SizedBox(height: 32),

                          // ── KEGIATAN TERBARU ──
                          const Text(
                            'KEGIATAN TERBARU',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 1.0),
                          ),
                          const SizedBox(height: 16),

                          // ── LIST KARTU KEGIATAN ──
                          Obx(() {
                            // Tampilkan loading saat data masih ditarik dari Supabase
                            if (controller.isLoading.value) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final items = controller.filteredKegiatan;

                            // Tampilkan pesan jika data kosong
                            if (items.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: Text("Belum ada laporan kegiatan", style: TextStyle(color: Colors.grey)),
                                ),
                              );
                            }

                            // Render list kegiatan
                            return Column(
                              children: items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: _buildKegiatanCard(item),
                              )).toList(),
                            );
                          }),
                          const SizedBox(height: 100), // Spasi bawah untuk navbar
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
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Get.back(),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.01), border: Border.all(color: Colors.white.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('Kelola Kegiatan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        onChanged: (val) => controller.searchQuery.value = val,
        decoration: InputDecoration(
          hintText: 'Cari kegiatan...',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Semua', 'Penyuluhan', 'Sosialisasi', 'Lainnya'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabs.map((tab) => _buildTabItem(tab)).toList(),
      ),
    );
  }

  Widget _buildTabItem(String title) {
    return Obx(() {
      bool isActive = controller.selectedTab.value == title;
      return GestureDetector(
        onTap: () => controller.changeTab(title),
        child: Container(
          padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isActive ? darkBlueColor : Colors.transparent, width: 3)),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? darkBlueColor : textSecondary,
            ),
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
            colors: [Color(0xFF3B418E), darkBlueColor], // Gradasi Biru-Ungu ke Biru Gelap
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
            borderRadius: BorderRadius.circular(50), // Bentuk Pill
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
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
          // Gambar Header & Badge
          Stack(
            children: [
              // ✅ AMAN DARI ERROR: Cek kalau item.imageUrl null, kasih gambar abu-abu
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
                top: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: darkBlueColor, borderRadius: BorderRadius.circular(8)),
                  child: Text(item.kategori.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),

          // Detail Teks Bawah
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

                // Footer Card (Avatar & Tombol Detail)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Mockup tumpukan Avatar
                    SizedBox(
                      width: 80, height: 32,
                      child: Stack(
                        children: [
                          Positioned(left: 0, child: CircleAvatar(radius: 16, backgroundColor: const Color(0xFFE2E8F0), child: Text('JD', style: TextStyle(fontSize: 10, color: darkBlueColor, fontWeight: FontWeight.bold)))),
                          Positioned(left: 20, child: CircleAvatar(radius: 16, backgroundColor: const Color(0xFFCBD5E1), child: Text('+12', style: TextStyle(fontSize: 10, color: darkBlueColor, fontWeight: FontWeight.bold)))),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.snackbar("Detail", "Membuka detail kegiatan ${item.judul}");
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