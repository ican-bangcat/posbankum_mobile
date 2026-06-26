import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kelola_pengaduan_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../models/kasus_model.dart';

class KelolaPengaduanView extends GetView<KelolaPengaduanController> {
  const KelolaPengaduanView({super.key});

  final Color darkBlue = const Color(0xFF2A2E5E);
  final Color bgColor = const Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    Get.put(KelolaPengaduanController());
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: darkBlue,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650.0),
          child: Column(
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
                                GestureDetector(
                                  onTap: () => Get.back(),
                                  child: Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                                  ),
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
                        child: _buildSearchBar(context),
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
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(child: CircularProgressIndicator());
                          }
    
                          final bool isCompact = controller.isCompactView.value;
    
                          // 🚀 JIKA TAB SEMUA (0), TAMPILKAN DENGAN PENGELOMPOKAN STATUS
                          if (controller.selectedTab.value == 0) {
                            final elements = controller.groupedListElements;
    
                            if (elements.isEmpty) {
                              return const Center(child: Text("Belum ada data pengaduan", style: TextStyle(color: Colors.grey)));
                            }
    
                            return RefreshIndicator(
                              onRefresh: () => controller.fetchPengaduan(isRefresh: true),
                              child: ListView.builder(
                                controller: controller.scrollController,
                                padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 30),
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: elements.length + (controller.isLoadingMore.value ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == elements.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }
                                  final el = elements[index];
                                  if (el is HeaderElement) {
                                    return _buildSectionHeader(el.title, el.count, isCompact: isCompact);
                                  } else {
                                    final kasus = (el as CardElement).kasus;
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: isCompact ? 8 : 12),
                                      child: isCompact
                                          ? _buildCompactCaseCardFromItem(kasus)
                                          : _buildCaseCardFromItem(kasus),
                                    );
                                  }
                                },
                              ),
                            );
                          }
    
                          // 🚀 JIKA TAB LAIN (1 ATAU 2), TAMPILKAN SEPERTI BIASA
                          final listKasus = controller.filteredKasus;
    
                          if (listKasus.isEmpty) {
                            return const Center(child: Text("Belum ada kasus di kategori ini", style: TextStyle(color: Colors.grey)));
                          }
    
                          return RefreshIndicator(
                            onRefresh: () => controller.fetchPengaduan(isRefresh: true),
                            child: ListView.builder(
                              controller: controller.scrollController,
                              padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 30),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: listKasus.length + (controller.isLoadingMore.value ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == listKasus.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                final kasus = listKasus[index];
                                return Padding(
                                  padding: EdgeInsets.only(bottom: isCompact ? 8 : 16),
                                  child: isCompact
                                      ? _buildCompactCaseCardFromItem(kasus)
                                      : _buildCaseCardFromItem(kasus),
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
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              onChanged: (val) => controller.searchQuery.value = val,
              decoration: const InputDecoration(
                hintText: 'Cari judul, kategori, atau lokasi...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Filter Button
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showFilterBottomSheet(context),
              child: Icon(
                Icons.tune_rounded,
                color: darkBlue,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Layout Toggle Button
        Obx(() {
          final isCompact = controller.isCompactView.value;
          return Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => controller.isCompactView.toggle(),
                child: Icon(
                  isCompact ? Icons.view_agenda_rounded : Icons.view_headline_rounded,
                  color: darkBlue,
                  size: 22,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4F6F9),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Data Kasus',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2452),
                      ),
                    ),
                    TextButton(
                      onPressed: () => controller.resetFilters(),
                      child: const Text(
                        'Reset Filter',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFFE2E8F0), thickness: 1.5, height: 16),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'URUTKAN BERDASARKAN',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 10),
                        Obx(() => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFilterChip(
                              label: 'Skor Prioritas',
                              value: 'priority',
                              selectedValue: controller.sortBy.value,
                              onSelected: (val) => controller.sortBy.value = val,
                            ),
                            _buildFilterChip(
                              label: 'Terbaru',
                              value: 'newest',
                              selectedValue: controller.sortBy.value,
                              onSelected: (val) => controller.sortBy.value = val,
                            ),
                            _buildFilterChip(
                              label: 'Terlama',
                              value: 'oldest',
                              selectedValue: controller.sortBy.value,
                              onSelected: (val) => controller.sortBy.value = val,
                            ),
                          ],
                        )),
                        const SizedBox(height: 20),
                        const Text(
                          'TINGKAT PRIORITAS',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 10),
                        Obx(() => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'Semua',
                            'Sangat Tinggi',
                            'Tinggi',
                            'Menengah',
                            'Normal',
                            'Rendah',
                          ].map((prio) {
                            return _buildFilterChip(
                              label: prio,
                              value: prio,
                              selectedValue: controller.filterPriority.value,
                              onSelected: (val) => controller.filterPriority.value = val,
                            );
                          }).toList(),
                        )),
                        const SizedBox(height: 20),
                        const Text(
                          'KATEGORI MASALAH',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 10),
                        Obx(() {
                          final categories = ['Semua', ...controller.allKasus.map((k) => k.kategori).toSet()];
                          final currentVal = categories.contains(controller.filterCategory.value)
                              ? controller.filterCategory.value
                              : 'Semua';
                          return GestureDetector(
                            onTap: () => _showCategoryPicker(context, categories),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    currentVal,
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Terapkan Filter',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showCategoryPicker(BuildContext context, List<String> categories) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Kategori Masalah',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2452),
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9), height: 1),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return Obx(() {
                        final isSelected = controller.filterCategory.value == cat;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? darkBlue : const Color(0xFF475569),
                            ),
                          ),
                          trailing: Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                            color: isSelected ? darkBlue : const Color(0xFFCBD5E1),
                            size: 20,
                          ),
                          onTap: () {
                            controller.filterCategory.value = cat;
                            Get.back();
                          },
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    final isSelected = value == selectedValue;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? darkBlue : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? darkBlue : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTabFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTabButton(text: 'Semua', index: 0, activeColor: darkBlue),
        const SizedBox(width: 10),
        _buildTabButton(text: 'Dalam Proses', index: 1, activeColor: Colors.blue.shade600),
        const SizedBox(width: 10),
        _buildTabButton(text: 'Selesai', index: 2, activeColor: Colors.green.shade600),
      ],
    );
  }

  Widget _buildTabButton({required String text, required int index, required Color activeColor}) {
    return Obx(() {
      final bool isActive = controller.selectedTab.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => controller.changeTab(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? activeColor : Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                topLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
              boxShadow: isActive
                  ? [BoxShadow(color: activeColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                  : [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
              border: isActive ? null : Border.all(color: Colors.grey.shade300),
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

  Widget _buildCaseCard({
    required String badgeText, required Color badgeColor, required Color badgeBg, IconData? badgeIcon,
    required String date, required String title, required String kategori,
    String? deskripsi, String? lokasi, String? namaKlien, String? lastUpdate,
    bool showButton = true, String? buttonText, VoidCallback? onTapButton,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapButton,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BARIS 1: Badge Status & Tanggal ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      if (badgeIcon != null) ...[Icon(badgeIcon, size: 14, color: badgeColor), const SizedBox(width: 4)],
                      Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                Text(date, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
  
            // --- BARIS 2: Judul Utama (Lebih Besar & Tegas) ---
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.3)),
            const SizedBox(height: 10),
  
            // --- BARIS 3: Kategori Masalah (Bentuk Tag/Label biar beda sama judul) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // Abu-abu terang
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.folder_special_rounded, size: 14, color: Color(0xFF475569)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      kategori,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
  
            // --- BARIS 4: Deskripsi (Kronologi Singkat) ---
            if (deskripsi != null) ...[
              Text(
                deskripsi,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
            ],
  
            // --- GARIS PEMBATAS ---
            const Divider(color: Color(0xFFF1F5F9), thickness: 1.5, height: 24),
  
            // --- BARIS 5: Info Meta (Lokasi, Klien) ---
            Row(
              children: [
                if (lokasi != null) Expanded(child: _buildMetaText(Icons.location_on_rounded, lokasi)),
                if (namaKlien != null) Expanded(child: _buildMetaText(Icons.person_rounded, namaKlien)),
                if (lastUpdate != null) Expanded(child: _buildMetaText(Icons.history_rounded, lastUpdate)),
              ],
            ),
  
            if (showButton) const SizedBox(height: 20),
            if (showButton)
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: onTapButton,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF161B33),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          (buttonText == 'Ambil Kasus' || buttonText == 'Ambil Kasus ->') ? 'Lihat Detail' : (buttonText ?? ''),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)
                      ),
                      const SizedBox(width: 8),
                      Icon(
                          (buttonText == 'Ambil Kasus' || buttonText == 'Ambil Kasus ->') ? Icons.arrow_forward_rounded : Icons.edit_rounded,
                          color: Colors.white,
                          size: 18
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, {bool isCompact = false}) {
    return Padding(
      padding: EdgeInsets.only(top: isCompact ? 16 : 24, bottom: isCompact ? 8 : 12),
      child: Row(
        children: [
          Container(
            width: 4, height: 16,
            decoration: BoxDecoration(
              color: darkBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E2452), letterSpacing: 0.5),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCardFromItem(KasusItem kasus) {
    final tanggalStr = "${kasus.tanggalPengajuan.day.toString().padLeft(2, '0')}/${kasus.tanggalPengajuan.month.toString().padLeft(2, '0')}/${kasus.tanggalPengajuan.year}";

    String badgeText = '';
    Color badgeColor = Colors.grey;
    Color badgeBg = Colors.grey.shade200;
    IconData? badgeIcon;
    bool showButton = false;
    String buttonText = '';

    if (kasus.status == 'menunggu') {
      showButton = true;
      buttonText = 'Ambil Kasus';

      int levelPrioritas = controller.getPriorityValue(kasus.prioritas);

      if (levelPrioritas == 1) {
        badgeText = 'MENUNGGU (URGENT)';
        badgeColor = const Color(0xFFEF4444);
        badgeBg = const Color(0xFFFEE2E2);
        badgeIcon = Icons.warning_rounded;
      } else {
        badgeText = 'MENUNGGU';
        badgeColor = const Color(0xFFF59E0B);
        badgeBg = const Color(0xFFFEF3C7);
        badgeIcon = Icons.hourglass_empty_rounded;
      }
    }
    else if (kasus.status == 'proses' || kasus.status == 'dalam proses' || kasus.status == 'diproses') {
      badgeText = 'DIPROSES';
      badgeColor = const Color(0xFF3B82F6);
      badgeBg = const Color(0xFFEFF6FF);
      badgeIcon = Icons.autorenew_rounded;
      showButton = true;
      buttonText = 'Update Progres';
    }
    else if (kasus.status == 'selesai') {
      badgeText = 'SELESAI';
      badgeColor = const Color(0xFF10B981);
      badgeBg = const Color(0xFFECFDF5);
      badgeIcon = Icons.check_circle_outline;
      showButton = false;
    }
    else if (kasus.status == 'dibatalkan') {
      badgeText = 'DIBATALKAN';
      badgeColor = const Color(0xFFEF4444);
      badgeBg = const Color(0xFFFEE2E2);
      badgeIcon = Icons.cancel_outlined;
      showButton = false;
    }

    return _buildCaseCard(
      badgeText: badgeText, badgeColor: badgeColor, badgeBg: badgeBg, badgeIcon: badgeIcon,
      date: tanggalStr,
      title: kasus.judul,
      kategori: kasus.kategori,
      deskripsi: kasus.status == 'menunggu' ? kasus.deskripsi : null,
      lokasi: (kasus.status == 'menunggu' || kasus.status == 'selesai') ? kasus.lokasi : null,
      namaKlien: kasus.status != 'menunggu' ? kasus.namaKlien : null,
      showButton: showButton, buttonText: buttonText,
      onTapButton: () {
        Get.toNamed(AppRoutes.DETAIL_KASUS_PARALEGAL, arguments: {'id': kasus.id});
      },
    );
  }

  Widget _buildCompactCaseCardFromItem(KasusItem kasus) {
    final tanggalStr = "${kasus.tanggalPengajuan.day.toString().padLeft(2, '0')}/${kasus.tanggalPengajuan.month.toString().padLeft(2, '0')}/${kasus.tanggalPengajuan.year}";

    String statusText = '';
    Color statusColor = Colors.grey;
    Color statusBg = Colors.grey.shade200;
    IconData statusIcon = Icons.help_outline;

    if (kasus.status == 'menunggu') {
      int levelPrioritas = controller.getPriorityValue(kasus.prioritas);
      if (levelPrioritas == 1) {
        statusText = 'Urgent';
        statusColor = const Color(0xFFEF4444);
        statusBg = const Color(0xFFFEE2E2);
        statusIcon = Icons.warning_rounded;
      } else {
        statusText = 'Menunggu';
        statusColor = const Color(0xFFF59E0B);
        statusBg = const Color(0xFFFEF3C7);
        statusIcon = Icons.hourglass_empty_rounded;
      }
    }
    else if (kasus.status == 'proses' || kasus.status == 'dalam proses' || kasus.status == 'diproses') {
      statusText = 'Diproses';
      statusColor = const Color(0xFF3B82F6);
      statusBg = const Color(0xFFEFF6FF);
      statusIcon = Icons.autorenew_rounded;
    }
    else if (kasus.status == 'selesai') {
      statusText = 'Selesai';
      statusColor = const Color(0xFF10B981);
      statusBg = const Color(0xFFECFDF5);
      statusIcon = Icons.check_circle_outline;
    }
    else if (kasus.status == 'dibatalkan') {
      statusText = 'Batal';
      statusColor = const Color(0xFFEF4444);
      statusBg = const Color(0xFFFEE2E2);
      statusIcon = Icons.cancel_outlined;
    }

    final shortId = kasus.id.length >= 8 ? '#${kasus.id.substring(0, 8)}' : '#${kasus.id}';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Get.toNamed(AppRoutes.DETAIL_KASUS_PARALEGAL, arguments: {'id': kasus.id});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: statusBg,
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        shortId,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      if (kasus.status == 'menunggu' && controller.getPriorityValue(kasus.prioritas) != 1) ...[
                        const SizedBox(width: 8),
                        Text(
                          kasus.prioritas,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kasus.judul,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.folder_open_rounded, size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          kasus.kategori,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '•',
                        style: TextStyle(color: Color(0xFFcbd5e1), fontSize: 10),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.person_outline_rounded, size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          kasus.status == 'menunggu' ? kasus.lokasi : (kasus.namaKlien ?? 'Masyarakat (Klien)'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tanggalStr,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFcbd5e1),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}