import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kelola_pengaduan_controller.dart';
import '../../../app/routes/app_routes.dart';

class KelolaPengaduanView extends GetView<KelolaPengaduanController> {
  const KelolaPengaduanView({super.key});

  final Color darkBlue = const Color(0xFF2A2E5E);
  final Color bgColor = const Color(0xFFF8FAFC);
  final Color indigoPrimary = const Color(0xFF3B4A8D); // Match detail page button color

  @override
  Widget build(BuildContext context) {
    Get.put(KelolaPengaduanController());

    return Scaffold(
      backgroundColor: darkBlue,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.zero, // Menghilangkan warna biru di sudut
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildSearchBar(),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildTabFilter(),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'KASUS TERSEDIA',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 1.0),
                        ),
                        Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            '${controller.filteredKasus.length} Kasus',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E2452)),
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final listKasus = controller.filteredKasus;

                      if (listKasus.isEmpty) {
                        return _buildEmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: () => controller.fetchPengaduan(),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: listKasus.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final kasus = listKasus[index];
                            final tanggalStr = "${kasus.tanggalPengajuan.day.toString().padLeft(2, '0')}/${kasus.tanggalPengajuan.month.toString().padLeft(2, '0')}/${kasus.tanggalPengajuan.year}";

                            String badgeText = '';
                            Color badgeColor = Colors.grey;
                            Color badgeBg = Colors.grey.shade200;
                            IconData? badgeIcon;

                            if (kasus.status == 'pending') {
                              int prioritas = controller.getPriorityValue(kasus.kategori);
                              if (prioritas == 1) {
                                badgeText = 'URGENT';
                                badgeColor = const Color(0xFFEF4444);
                                badgeBg = const Color(0xFFFEE2E2);
                              } else {
                                badgeText = 'BELUM DIPROSES';
                                badgeColor = const Color(0xFFF59E0B);
                                badgeBg = const Color(0xFFFEF3C7);
                              }
                            } else if (kasus.status == 'proses' || kasus.status == 'dalam proses' || kasus.status == 'diproses') {
                              badgeText = 'SEDANG DIPROSES';
                              badgeColor = const Color(0xFF3B82F6);
                              badgeBg = const Color(0xFFEFF6FF);
                            } else if (kasus.status == 'selesai') {
                              badgeText = 'KASUS SELESAI';
                              badgeColor = const Color(0xFF10B981);
                              badgeBg = const Color(0xFFECFDF5);
                              badgeIcon = Icons.check_circle_outline;
                            }

                            return _buildCaseCard(
                              idKasus: kasus.id,
                              badgeText: badgeText, badgeColor: badgeColor, badgeBg: badgeBg, badgeIcon: badgeIcon,
                              date: tanggalStr,
                              title: kasus.judul,
                              kategori: kasus.kategori,
                              lokasi: kasus.lokasi,
                              namaKlien: kasus.namaKlien,
                              onTapButton: () {
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
            child: const Icon(Icons.assignment_outlined, size: 64, color: Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 24),
          const Text('Belum ada kasus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E2452))),
          const SizedBox(height: 8),
          const Text('Tidak ada pengaduan yang sesuai\ndengan filter saat ini.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF94A3B8), height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
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
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Kelola Data Kasus',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 0.5),
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        onChanged: (val) => controller.searchQuery.value = val,
        decoration: InputDecoration(
          hintText: 'Cari berdasarkan judul atau lokasi...', 
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 22),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildTabFilter() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'Semua'),
          _buildTabItem(1, 'Proses'),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? indigoPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              title, textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13, fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCaseCard({
    required String idKasus,
    required String badgeText, required Color badgeColor, required Color badgeBg, IconData? badgeIcon,
    required String date, required String title, required String kategori,
    String? lokasi, String? namaKlien, required VoidCallback onTapButton,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: badgeColor, width: 6)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                  child: Text('ID: #${idKasus.toUpperCase()}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w800, fontFamily: 'Monospace')),
                ),
                Text(date, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E2452), height: 1.3)),
            const SizedBox(height: 4),
            Text(kategori, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6))),
            const SizedBox(height: 16),
            
            if (namaKlien != null || lokasi != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    if (namaKlien != null) _buildInfoRow(Icons.person_outline, namaKlien),
                    if (namaKlien != null && lokasi != null) const SizedBox(height: 8),
                    if (lokasi != null) _buildInfoRow(Icons.location_on_outlined, lokasi),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      if (badgeIcon != null) ...[Icon(badgeIcon, size: 12, color: badgeColor), const SizedBox(width: 4)]
                      else ...[Container(width: 6, height: 6, decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle)), const SizedBox(width: 6)],
                      Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onTapButton,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: indigoPrimary, borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      children: [
                        Text('Detail', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text, 
            style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w600), 
            maxLines: 1, overflow: TextOverflow.ellipsis
          )
        ),
      ],
    );
  }
}