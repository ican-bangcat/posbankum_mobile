import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_pengaduan_controller.dart';

class RiwayatPengaduanView extends GetView<RiwayatPengaduanController> {
  const RiwayatPengaduanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2E5E), // Warna Biru Gelap Header
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE (GEDUNG/PALU) DI HEADER
          Positioned(
            top: 50,
            right: -20, // Geser dikit biar artistik
            child: Opacity(
              opacity: 0.2, // Biar transparan kaya di desain
              child: Image.asset(
                'assets/images/header_illustration.png', // Pastikan file sudah ada
                width: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 2. KONTEN UTAMA
          Column(
            children: [
              // --- HEADER (Judul & Back Button) ---
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      // Tombol Back Custom
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
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
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- BODY (WARNA PUTIH MELENGKUNG) ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5), // Warna abu-abu terang background body
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // SEARCH BAR
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildSearchBar(controller),
                      ),

                      const SizedBox(height: 20),

                      // TAB FILTER (Semua, Dalam Proses, Selesai)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildTabFilter(controller),
                      ),

                      const SizedBox(height: 20),

                      // LIST PENGADUAN
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (controller.filteredItems.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                                  const SizedBox(height: 10),
                                  Text("Belum ada pengaduan", style: TextStyle(color: Colors.grey[500])),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            itemCount: controller.filteredItems.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return _buildCardItem(controller.filteredItems[index]);
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET: SEARCH BAR ---
  Widget _buildSearchBar(RiwayatPengaduanController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          hintText: 'Cari pengaduan',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // --- WIDGET: TAB FILTER ---
  Widget _buildTabFilter(RiwayatPengaduanController controller) {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Container luar rounded
      ),
      child: Row(
        children: [
          _buildTabButton('Semua', StatusPengaduan.semua, controller),
          _buildTabButton('Dalam Proses', StatusPengaduan.dalamProses, controller),
          _buildTabButton('Selesai', StatusPengaduan.selesai, controller),
        ],
      ),
    ));
  }

  Widget _buildTabButton(String text, StatusPengaduan tab, RiwayatPengaduanController controller) {
    bool isActive = controller.selectedTab.value == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE7EDFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8), // Button dalam rounded
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? const Color(0xFF3B5BDB) : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET: CARD ITEM ---
  Widget _buildCardItem(PengaduanItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(40), // Radius Unik Kanan Bawah
        ),
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
          // Baris Atas: Judul & Status
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.judul,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.tanggal,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(item.status),
              ],
            ),
          ),

          // Garis Pemisah
          Divider(height: 1, color: Colors.grey[200]),

          // Baris Bawah: ID Tiket & Tombol Panah
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Icon(Icons.confirmation_number_outlined, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Text(
                  item.idTiket,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
                const Spacer(),
                // Tombol Panah Biru
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2A2E5E), // Warna Biru Gelap
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
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
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;

    // Logika Warna Status
    if (status.toLowerCase().contains('selesai')) {
      bg = const Color(0xFFE8F5E9); text = const Color(0xFF2E7D32);
    } else if (status.toLowerCase().contains('proses')) {
      bg = const Color(0xFFE3F2FD); text = const Color(0xFF1565C0);
    } else {
      bg = const Color(0xFFFFF3E0); text = const Color(0xFFE65100);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: text),
      ),
    );
  }
}