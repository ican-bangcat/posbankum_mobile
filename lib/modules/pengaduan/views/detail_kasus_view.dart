import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      if (kasus == null) return const Scaffold(backgroundColor: whiteBgColor, body: Center(child: Text('Data tidak ditemukan')));

      final String statusKasus = (kasus.status).toLowerCase().trim();
      bool isSelesai = statusKasus == 'selesai';

      return Scaffold(
        backgroundColor: darkBlueColor,
        body: isSelesai ? _buildSelesaiLayout(kasus, isSelesai) : _buildProsesLayout(kasus, isSelesai, statusKasus),
      );
    });
  }

  // ── LAYOUT PROSES / PENDING ──
  Widget _buildProsesLayout(DetailKasus kasus, bool isSelesai, String statusKasus) {
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
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
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
                                  child: Text(kasus.idKasus, style: const TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.w800)),
                                ),
                                const SizedBox(width: 12),
                                Text(kasus.tanggalDibuat, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            // Label Status Dibatalkan
                            if (statusKasus == 'dibatalkan')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                                child: const Text('Dibatalkan', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                              )
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ✅ HIERARKI TEKS (Sesuai Permintaan)
                        Text(kasus.judulLaporan, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary, height: 1.3)),
                        const SizedBox(height: 8),
                        Text(kasus.kategoriMasalah, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: darkBlueColor)),
                        const SizedBox(height: 12),
                        Text(kasus.kronologi, style: const TextStyle(fontSize: 14, color: textSecondary, height: 1.6)),

                        const SizedBox(height: 32),
                        const Text('Perjalanan Kasus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                        const SizedBox(height: 20),
                        _buildTimelineSection(kasus),

                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Berkas & Dokumen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                            Text('${kasus.lampiranUrls.length} File', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ✅ RENDER FILE DINAMIS DARI DATABASE
                        if (kasus.lampiranUrls.isEmpty)
                          const Text('Tidak ada dokumen terlampir.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                        else
                          _buildDokumenGrid(kasus.lampiranUrls),
                      ],
                    ),
                  ),
                ),

                // ✅ LOGIKA TOMBOL BAWAH
                if (statusKasus == 'diproses')
                  _buildChatButton()
                else if (statusKasus == 'pending')
                  _buildBatalkanButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ✅ GRID LAMPIRAN DINAMIS
  Widget _buildDokumenGrid(List<String> urls) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.80,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: urls.length,
      itemBuilder: (context, index) {
        String url = urls[index];
        bool isPdf = url.toLowerCase().contains('.pdf');
        String fileName = url.split('/').last.split('?').first;
        if (fileName.length > 25) fileName = '${fileName.substring(0, 20)}...';

        return GestureDetector(
          onTap: () => controller.bukaLampiran(url), // ✅ Lempar ke URL Launcher
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
                            : Image.network(url, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image, color: Colors.grey))),
                      ),
                      Positioned(
                        top: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF475569).withOpacity(0.9), borderRadius: BorderRadius.circular(6)),
                          child: Text(isPdf ? 'PDF' : 'IMAGE', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
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
                        Text(fileName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
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

  // ✅ TOMBOL BATALKAN (Khusus Pending)
  Widget _buildBatalkanButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(color: whiteBgColor, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, -5))]),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            Get.defaultDialog(
                title: "Batalkan Pengaduan?",
                middleText: "Apakah Anda yakin ingin membatalkan pengaduan ini?",
                textCancel: "Tidak",
                textConfirm: "Ya, Batalkan",
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () {
                  Get.back();
                  controller.batalkanPengaduan();
                }
            );
          },
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
          ),
          child: const Text('Batalkan Pengaduan', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      ),
    );
  }

  // ✅ TOMBOL CHAT (Khusus Diproses)
  Widget _buildChatButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(color: whiteBgColor, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, -5))]),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Get.snackbar('Info', 'Fitur Chat segera hadir!'),
          style: ElevatedButton.styleFrom(backgroundColor: darkBlueColor, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20), SizedBox(width: 8), Text('Chat Paralegal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))]
          ),
        ),
      ),
    );
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
                      const Text('Detail Kasus', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
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

  // ── TIMELINE ──
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
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isCurrent ? darkBlueColor : (isDone ? textPrimary : const Color(0xFF94A3B8)))),
                      const SizedBox(height: 6),
                      Text(item.tanggal ?? (isCurrent ? 'Tim paralegal sedang memproses pengaduan.' : 'Menunggu proses selanjutnya'), style: TextStyle(fontSize: 13, color: isDone ? textSecondary : const Color(0xFF94A3B8), height: 1.5)),
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

  // ── SELESAI LAYOUT (Tetap sama seperti punyamu sebelumnya, cuma dipadatin) ──
  Widget _buildSelesaiLayout(DetailKasus kasus, bool isSelesai) {
    return Column(
      children: [
        _buildHeader(isSelesai),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: bgSelesai, borderRadius: BorderRadius.only(topRight: Radius.circular(28), topLeft: Radius.zero)),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
              child: Column(
                children: [
                  // Teks Selesai Header
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 50),
                        const SizedBox(height: 12),
                        const Text('PERKARA SELESAI', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(kasus.judulLaporan, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                  // ...(Bagian selesai lainnya tetap bisa kamu pakai dari kodinganmu yang lama)
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}