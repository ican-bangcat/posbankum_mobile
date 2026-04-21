import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kelola_pengaduan_controller.dart';
import '../../../app/routes/app_routes.dart';
class KelolaPengaduanView extends GetView<KelolaPengaduanController> {
  const KelolaPengaduanView({super.key});

  final Color darkBlue = const Color(0xFF2A2E5E);
  final Color bgColor = const Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller
    Get.put(KelolaPengaduanController());

    return Scaffold(
      backgroundColor: darkBlue,
      body: Column(
        children: [
          // ─── 1. HEADER ───
          Stack(
            children: [
              Positioned(
                bottom: 0, left: 0,
                child: Container(width: 50, height: 50, color: bgColor),
              ),
              Container(
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: darkBlue,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -10, right: -5,
                      child: Opacity(
                        opacity: 0.8,
                        child: Image.asset(
                          'assets/images/icons/building_illustration3.png',
                          width: 300, fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.account_balance, size: 150, color: Colors.white10),
                        ),
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Kelola Data Kasus',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5),
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

          // ─── 2. BODY DINAMIS ───
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSearchBar(),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildTabFilter(),
                  ),
                  const SizedBox(height: 20),

                  // Label Kasus Tersedia
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'KASUS TERSEDIA',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 1.0),
                        ),
                        Obx(() => Text(
                          '${controller.filteredKasus.length} Kasus',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // List Kasus Dinamis
                  Expanded(
                    child: Obx(() {
                      // Menampilkan Loading saat mengambil data dari Supabase
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final listKasus = controller.filteredKasus;

                      if (listKasus.isEmpty) {
                        return const Center(child: Text("Belum ada kasus di kategori ini", style: TextStyle(color: Colors.grey)));
                      }

                      return RefreshIndicator(
                        onRefresh: () => controller.fetchPengaduan(),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                          physics: const AlwaysScrollableScrollPhysics(), // Agar selalu bisa ditarik walau itemnya 1
                          itemCount: listKasus.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final kasus = listKasus[index];

                            // FORMAT TANGGAL
                            final tanggalStr = "${kasus.tanggalPengajuan.day.toString().padLeft(2, '0')}/${kasus.tanggalPengajuan.month.toString().padLeft(2, '0')}/${kasus.tanggalPengajuan.year}";

                            // LOGIKA UI BERDASARKAN STATUS
                            String badgeText = '';
                            Color badgeColor = Colors.grey;
                            Color badgeBg = Colors.grey.shade200;
                            IconData? badgeIcon;
                            bool showButton = false;
                            String buttonText = '';

                            if (kasus.status == 'pending') {
                              showButton = true;
                              buttonText = 'Ambil Kasus ->';
                              int prioritas = controller.getPriorityValue(kasus.kategori);

                              if (prioritas == 1) { // KASTA VISUAL: URGENT!
                                badgeText = 'URGENT';
                                badgeColor = const Color(0xFFEF4444);
                                badgeBg = const Color(0xFFFEE2E2);
                              } else { // KASTA VISUAL: BIASA
                                badgeText = 'MENUNGGU';
                                badgeColor = const Color(0xFFF59E0B);
                                badgeBg = const Color(0xFFFEF3C7);
                              }
                            }
                            else if (kasus.status == 'proses' || kasus.status == 'dalam proses' || kasus.status == 'diproses') {
                              badgeText = 'SEDANG PROSES';
                              badgeColor = const Color(0xFF3B82F6);
                              badgeBg = const Color(0xFFEFF6FF);
                              showButton = true;
                              buttonText = 'Update Progres ✎';
                            }
                            else if (kasus.status == 'selesai') {
                              badgeText = 'SELESAI';
                              badgeColor = const Color(0xFF10B981);
                              badgeBg = const Color(0xFFECFDF5);
                              badgeIcon = Icons.check_circle_outline;
                              showButton = false;
                            }

                            return _buildCaseCard(
                              badgeText: badgeText, badgeColor: badgeColor, badgeBg: badgeBg, badgeIcon: badgeIcon,
                              date: tanggalStr,
                              title: kasus.judul,
                              deskripsi: kasus.status == 'pending' ? kasus.deskripsi : null,
                              lokasi: (kasus.status == 'pending' || kasus.status == 'selesai') ? kasus.lokasi : null,
                              namaKlien: kasus.status != 'pending' ? kasus.namaKlien : null,
                              showButton: showButton, buttonText: buttonText,
                              onTapButton: () {
                                // ✅ NAVIGASI KE DETAIL Sambil Membawa ID
                                Get.toNamed(AppRoutes.DETAIL_KASUS_PARALEGAL, arguments: {'id': kasus.id});
                              },
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
    );
  }

  // ─── KOMPONEN UI ───
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        onChanged: (val) => controller.searchQuery.value = val,
        decoration: const InputDecoration(
          hintText: 'Cari pengaduan...', hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
          border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildTabFilter() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildTabItem(0, 'Semua'),
          _buildTabItem(1, 'Dalam Proses'),
          _buildTabItem(2, 'Selesai'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    return Expanded(
      child: Obx(() {
        final bool isActive = controller.selectedTab.value == index;
        return GestureDetector(
          onTap: () => controller.changeTab(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFEFF6FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title, textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? darkBlue : const Color(0xFF64748B),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCaseCard({
    required String badgeText, required Color badgeColor, required Color badgeBg, IconData? badgeIcon,
    required String date, required String title,
    String? deskripsi, String? lokasi, String? namaKlien, String? lastUpdate,
    bool showButton = true, String? buttonText, VoidCallback? onTapButton,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    if (badgeIcon != null) ...[Icon(badgeIcon, size: 12, color: badgeColor), const SizedBox(width: 4)],
                    Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  ],
                ),
              ),
              Text(date, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.3)),
          const SizedBox(height: 8),

          if (deskripsi != null) ...[
            Text(
              deskripsi,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5),
              maxLines: 2, // Mencegah teks terlalu panjang merusak UI
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],

          Row(
            children: [
              if (lokasi != null) Expanded(child: _buildMetaText(Icons.location_on_outlined, lokasi)),
              if (namaKlien != null) Expanded(child: _buildMetaText(Icons.person_outline, namaKlien)),
              if (lastUpdate != null) Expanded(child: _buildMetaText(Icons.history, lastUpdate)),
            ],
          ),

          if (showButton) const SizedBox(height: 16),
          if (showButton)
            SizedBox(
              width: double.infinity, height: 44,
              child: ElevatedButton(
                onPressed: onTapButton,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF161B33),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0,
                ),
                // ✅ PERBAIKAN: Menggunakan Row untuk menempatkan Teks dan Icon Panah
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      // Jika status pending, gunakan 'Lihat Detail', selain itu ikuti buttonText bawaan (Update Progres)
                        buttonText == 'Ambil Kasus ->' ? 'Lihat Detail' : (buttonText ?? ''),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      // Icon panah untuk 'Lihat Detail', icon pensil/edit untuk 'Update Progres'
                        buttonText == 'Ambil Kasus ->' ? Icons.arrow_forward_rounded : Icons.edit,
                        color: Colors.white,
                        size: 16
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetaText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}