import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/detail_kasus_controller.dart';

class DetailKasusView extends GetView<DetailKasusController> {
  const DetailKasusView({super.key});

  static const Color darkBlueColor = Color(0xFF2A2E5E);
  static const Color whiteBgColor = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color bgSelesai = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(backgroundColor: whiteBgColor, body: Center(child: CircularProgressIndicator()));
      }

      final kasus = controller.kasus.value;
      if (kasus == null) return const Scaffold(backgroundColor: whiteBgColor, body: Center(child: Text('Data tidak ditemukan', style: TextStyle(fontFamily: 'Poppins'))));

      final String statusKasus = (kasus.status).toLowerCase().trim();
      bool isSelesai = statusKasus == 'selesai';

      final double bottomPadding = MediaQuery.of(context).padding.bottom;

      return Scaffold(
        backgroundColor: darkBlueColor,
        body: isSelesai
            ? _buildSelesaiLayout(kasus, isSelesai, bottomPadding)
            : _buildProsesLayout(kasus, isSelesai, statusKasus, bottomPadding),
      );
    });
  }

  // ── HEADER S-CURVE ──
  Widget _buildHeader(bool isSelesai) {
    Color patchColor = isSelesai ? bgSelesai : whiteBgColor;
    return Stack(
      children: [
        Positioned(bottom: 0, left: 0, child: SizedBox(width: 50, height: 50, child: DecoratedBox(decoration: BoxDecoration(color: patchColor)))),
        Container(
          width: double.infinity, clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(color: darkBlueColor, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.zero)),
          child: Stack(
            children: [
              Positioned(top: -10, right: -5, child: Opacity(opacity: 0.8, child: Image.asset('assets/images/icons/building_illustration3.png', width: 300, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.location_city, size: 200, color: Colors.white10)))),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  child: Row(
                    children: [
                      Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => Get.back(), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.01), border: Border.all(color: Colors.white.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)))),
                      const SizedBox(width: 16),
                      const Text('Detail Kasus', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5, fontFamily: 'Poppins')),
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

  // ===========================================================================
  // 🟢 LAYOUT SELESAI (SESUAI FIGMA + LAMPIRAN & DATA ASLI)
  // ===========================================================================
  Widget _buildSelesaiLayout(DetailKasus kasus, bool isSelesai, double bottomPadding) {
    return Column(
      children: [
        _buildHeader(isSelesai),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: bgSelesai, borderRadius: BorderRadius.only(topRight: Radius.circular(28), topLeft: Radius.zero)),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 24, 20, 40 + bottomPadding),
              child: Column(
                children: [
                  // --- CARD 1: HEADER INFO SELESAI ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
                          child: const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 40),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
                          child: const Text('PERKARA SELESAI', style: TextStyle(color: Color(0xFF166534), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, fontFamily: 'Poppins')),
                        ),
                        const SizedBox(height: 16),
                        Text(kasus.judulLaporan, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary, height: 1.3, fontFamily: 'Poppins')),
                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFFF1F5F9), thickness: 1.5, height: 0),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfoCol('NO. PERKARA', kasus.idKasus, isBold: true),
                            Container(width: 1.5, height: 40, color: const Color(0xFFF1F5F9)),
                            _buildInfoCol('TGL. SELESAI', kasus.tanggalSelesai ?? '-', color: const Color(0xFF22C55E), isBold: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- CARD 2: ALUR PENANGANAN ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Alur Penanganan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary, fontFamily: 'Poppins')),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                              child: const Text('100% Tuntas', style: TextStyle(color: Color(0xFF166534), fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                            )
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildSelesaiTimelineSection(kasus),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- CARD 3: DETAIL KEJADIAN ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Detail Kejadian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary, fontFamily: 'Poppins')),
                        const SizedBox(height: 20),
                        _buildDetailItem(Icons.calendar_today_outlined, 'Tanggal', kasus.tanggalDibuat),
                        const SizedBox(height: 16),
                        _buildDetailItem(Icons.assignment_outlined, 'Jenis Masalah', kasus.kategoriMasalah),
                        const SizedBox(height: 16),
                        // ✅ MENGGUNAKAN DATA LOKASI ASLI
                        _buildDetailItem(Icons.location_on_outlined, 'Lokasi', kasus.lokasi),
                        const SizedBox(height: 16),
                        // ✅ MENGGUNAKAN DATA NAMA PELAPOR ASLI
                        _buildDetailItem(Icons.person_outline, 'Data Pelapor', kasus.namaPelapor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- CARD 4: KRONOLOGI KEJADIAN ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kronologi Kejadian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary, fontFamily: 'Poppins')),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            const Text('PENGADUAN RESMI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B), letterSpacing: 0.5, fontFamily: 'Poppins')),
                            const SizedBox(width: 8),
                            Text('•  ${kasus.tanggalDibuat}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: textSecondary, fontFamily: 'Poppins')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          kasus.kronologi,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.6, fontWeight: FontWeight.w400, fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- CARD 5: BERKAS & DOKUMEN ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Berkas & Dokumen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary, fontFamily: 'Poppins')),
                            Text('${kasus.lampiranUrls.length} File', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary, fontFamily: 'Poppins')),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (kasus.lampiranUrls.isEmpty)
                          const Text('Tidak ada dokumen terlampir.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13, fontFamily: 'Poppins'))
                        else
                          _buildDokumenGrid(kasus.lampiranUrls),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Khusus Timeline saat Selesai (UI Garis Hijau & Highlight)
  Widget _buildSelesaiTimelineSection(DetailKasus kasus) {
    return Column(
      children: List.generate(kasus.timeline.length, (index) {
        final item = kasus.timeline[index];
        final isLast = index == kasus.timeline.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    const SizedBox(height: 2),
                    isLast
                        ? Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: const Color(0xFF22C55E), width: 2.5)),
                      child: Center(child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle))),
                    )
                        : Container(
                      width: 18, height: 18,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF22C55E)),
                      child: const Icon(Icons.check, color: Colors.white, size: 12),
                    ),
                    if (!isLast) Expanded(child: Container(width: 2, color: const Color(0xFF22C55E), margin: const EdgeInsets.symmetric(vertical: 4))),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                  child: isLast
                      ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), border: Border.all(color: const Color(0xFFDCFCE7)), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.insert_drive_file_outlined, color: Color(0xFF166534), size: 16),
                            const SizedBox(width: 8),
                            Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF166534), fontFamily: 'Poppins')),
                          ],
                        ),
                        if (item.description != null && item.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(item.description!, style: const TextStyle(fontSize: 12, color: Color(0xFF15803D), height: 1.5, fontFamily: 'Poppins')),
                        ],
                      ],
                    ),
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary, fontFamily: 'Poppins')),
                      const SizedBox(height: 4),
                      Text(
                          "${item.tanggal ?? ''} ${item.description != null && item.description!.isNotEmpty ? '• ${item.description}' : ''}",
                          style: const TextStyle(fontSize: 12, color: textSecondary, height: 1.4, fontFamily: 'Poppins')
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, color: textPrimary, fontWeight: FontWeight.w600, height: 1.4, fontFamily: 'Poppins')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCol(String label, String value, {Color? color, bool isBold = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textSecondary, letterSpacing: 0.5, fontFamily: 'Poppins')),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.w600, color: color ?? textPrimary, fontFamily: 'Poppins')),
      ],
    );
  }

  // ===========================================================================
  // 🔵 LAYOUT PROSES / PENDING (Aman, Tipografi Rapih)
  // ===========================================================================
  Widget _buildProsesLayout(DetailKasus kasus, bool isSelesai, String statusKasus, double bottomPadding) {
    final bool hasBottomButton = statusKasus == 'diproses' || statusKasus == 'pending' || statusKasus == 'menunggu';

    return Column(
      children: [
        _buildHeader(isSelesai),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: whiteBgColor, borderRadius: BorderRadius.only(topRight: Radius.circular(28), topLeft: Radius.zero)),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(24, 32, 24, hasBottomButton ? 24 : 24 + bottomPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20)),
                                  child: Text(kasus.idKasus, style: const TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                                ),
                                const SizedBox(width: 12),
                                Text(kasus.tanggalDibuat, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
                              ],
                            ),
                            if (statusKasus == 'dibatalkan')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                                child: const Text('Dibatalkan', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                              )
                          ],
                        ),
                        const SizedBox(height: 16),

                        Text(kasus.judulLaporan, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary, height: 1.3, fontFamily: 'Poppins')),
                        const SizedBox(height: 8),
                        Text(kasus.kategoriMasalah, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: darkBlueColor, fontFamily: 'Poppins')),
                        const SizedBox(height: 12),
                        Text(kasus.kronologi, style: const TextStyle(fontSize: 13, color: textSecondary, height: 1.6, fontWeight: FontWeight.w400, fontFamily: 'Poppins')),

                        const SizedBox(height: 32),
                        const Text('Perjalanan Kasus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary, fontFamily: 'Poppins')),
                        const SizedBox(height: 20),
                        _buildTimelineSection(kasus),

                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Berkas & Dokumen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary, fontFamily: 'Poppins')),
                            Text('${kasus.lampiranUrls.length} File', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary, fontFamily: 'Poppins')),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (kasus.lampiranUrls.isEmpty)
                          const Text('Tidak ada dokumen terlampir.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13, fontFamily: 'Poppins'))
                        else
                          _buildDokumenGrid(kasus.lampiranUrls),
                      ],
                    ),
                  ),
                ),

                if (statusKasus == 'diproses')
                  _buildChatButton(bottomPadding)
                else if (statusKasus == 'pending' || statusKasus == 'menunggu')
                  _buildBatalkanButton(bottomPadding),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDokumenGrid(List<LampiranItem> urls) {
    final token = GetStorage().read('token');
    final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.80,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: urls.length,
      itemBuilder: (context, index) {
        LampiranItem file = urls[index];
        bool isPdf = file.mimeType?.toLowerCase().contains('pdf') ?? file.namaFile.toLowerCase().endsWith('.pdf');
        String fileName = file.namaFile;
        if (fileName.length > 25) fileName = '${fileName.substring(0, 20)}...';

        return GestureDetector(
          onTap: () => controller.bukaLampiran(file.pathFile, file.mimeType, namaFile: file.namaFile),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                        child: isPdf
                            ? Container(color: const Color(0xFFFFF6F5), child: const Center(child: Icon(Icons.picture_as_pdf_rounded, size: 48, color: Color(0xFFEF4444))))
                            : Image.network(file.pathFile, headers: headers, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image, color: Colors.grey))),
                      ),
                      Positioned(
                        top: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF475569).withOpacity(0.9), borderRadius: BorderRadius.circular(6)),
                          child: Text(isPdf ? 'PDF' : 'IMAGE', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(fileName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textPrimary, fontFamily: 'Poppins'), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBatalkanButton(double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomPadding),
      decoration: BoxDecoration(
          color: whiteBgColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, -5))]
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            Get.dialog(
              Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Batalkan Pengaduan?',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black, fontFamily: 'Poppins'),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Pengaduan yang dibatalkan tidak akan diproses oleh tim paralegal. Anda yakin ingin melanjutkan?',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5, fontFamily: 'Poppins'),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Get.back(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F5F9),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text('Kembali', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569), fontFamily: 'Poppins')),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Get.back();
                                controller.batalkanPengaduan();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text('Ya, Batalkan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'Poppins')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
          ),
          child: const Text('Batalkan Pengaduan', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Poppins')),
        ),
      ),
    );
  }

  Widget _buildChatButton(double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomPadding),
      decoration: BoxDecoration(color: whiteBgColor, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, -5))]),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Get.snackbar('Info', 'Fitur Chat segera hadir!'),
          style: ElevatedButton.styleFrom(backgroundColor: darkBlueColor, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20), SizedBox(width: 8), Text('Chat Paralegal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Poppins'))]
          ),
        ),
      ),
    );
  }

  // Khusus Timeline saat belum selesai
  Widget _buildTimelineSection(DetailKasus kasus) {
    int lastActiveIndex = kasus.timeline.lastIndexWhere((t) => t.isActive == true);
    return Column(
      children: List.generate(kasus.timeline.length, (index) {
        final item = kasus.timeline[index];
        final isLast = index == kasus.timeline.length - 1;
        bool isCurrent = index == lastActiveIndex;
        bool isDone = index < lastActiveIndex;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: 20, child: Column(children: [const SizedBox(height: 4), _buildTimelineDot(isCurrent, isDone), if (!isLast) Expanded(child: Container(width: 1.5, color: isDone ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0), margin: const EdgeInsets.symmetric(vertical: 4)))])),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isCurrent ? darkBlueColor : (isDone ? textPrimary : const Color(0xFF94A3B8)), fontFamily: 'Poppins')),
                      const SizedBox(height: 4),
                      Text(item.tanggal ?? (isCurrent ? 'Tim paralegal sedang memproses pengaduan.' : 'Menunggu proses selanjutnya'), style: TextStyle(fontSize: 12, color: isDone ? textSecondary : const Color(0xFF94A3B8), height: 1.5, fontFamily: 'Poppins')),
                      if (item.description != null && item.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(item.description!, style: const TextStyle(fontSize: 12, color: textSecondary, height: 1.5, fontFamily: 'Poppins')),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTimelineDot(bool isCurrent, bool isDone) {
    if (isCurrent) return Container(width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.circle, color: darkBlueColor, border: Border.all(color: const Color(0xFFFDE68A), width: 3)));
    if (isDone) return Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFCBD5E1)));
    return Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: whiteBgColor, border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5)));
  }
}
