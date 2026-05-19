import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../controllers/detail_kasus_controller.dart';

class DetailKasusView extends GetView<DetailKasusController> {
  const DetailKasusView({super.key});

  // ── WARNA UTAMA ──
  static const Color darkBlueColor = Color(0xFF2A2E5E);
  static const Color whiteBgColor = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color orangeAccent = Color(0xFFF59E0B);
  static const Color bgSelesai = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          backgroundColor: whiteBgColor,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final kasus = controller.kasus.value;
      if (kasus == null) {
        return const Scaffold(
          backgroundColor: whiteBgColor,
          body: Center(child: Text('Data tidak ditemukan')),
        );
      }

      // ✅ FIX STATUS
      final String statusKasus = (kasus.status ?? '').toString().toLowerCase().trim();
      bool isSelesai = statusKasus == 'selesai';

      return Scaffold(
        // ✅ Scaffold selalu darkBlueColor agar Header menyatu sempurna
        backgroundColor: darkBlueColor,
        body: isSelesai ? _buildSelesaiLayout(kasus, isSelesai) : _buildProsesLayout(kasus, isSelesai),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════════
  //  LAYOUT 1: KETIKA STATUS "PROSES / PENDING"
  // ════════════════════════════════════════════════════════════════════
  Widget _buildProsesLayout(DetailKasus kasus, bool isSelesai) {
    return Column(
      children: [
        _buildHeader(isSelesai),
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
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF), // Lighter blue
                                borderRadius: BorderRadius.circular(20), // Pill shape
                              ),
                              child: Text(
                                kasus.idKasus.toUpperCase(),
                                style: const TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(kasus.tanggalDibuat, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(kasus.judulKasus, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary, height: 1.3)),
                        const SizedBox(height: 12),
                        Text(kasus.kronologi, style: const TextStyle(fontSize: 14, color: textSecondary, height: 1.6)),
                        const SizedBox(height: 32),
                        const Text('Perjalanan Kasus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                        const SizedBox(height: 20),
                        _buildTimelineSection(kasus),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Berkas & Dokumen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                            Text('4 File', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDokumenGrid(),
                      ],
                    ),
                  ),
                ),
                _buildBottomButtons(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDokumenGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.75, // Matches the image aspect ratio
      padding: EdgeInsets.zero,
      children: [
        _buildDokumenCard(isPdf: true, title: 'Surat Permohonan Bantuan Hukum.pdf', size: '2.4 MB', date: '12 Jan 2024'),
        _buildDokumenCard(isPdf: false, title: 'Foto Lokasi Tanah Sengketa.jpg', size: '3.1 MB', date: '12 Jan 2024', imageUrl: 'https://picsum.photos/id/40/200/300'),
        _buildDokumenCard(isPdf: true, title: 'Sertifikat Tanah.pdf', size: '1.8 MB', date: '13 Jan 2024'),
        _buildDokumenCard(isPdf: false, title: 'KTP Pelapor.jpg', size: '856 KB', date: '13 Jan 2024', imageUrl: 'https://picsum.photos/id/20/200/300'),
      ],
    );
  }

  Widget _buildDokumenCard({required bool isPdf, required String title, required String size, required String date, String? imageUrl}) {
    return GestureDetector(
      onTap: () => _showPreviewDialog(isPdf, title, imageUrl),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Half (Image or PDF Icon)
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                    child: isPdf 
                        ? Container(
                            color: const Color(0xFFFFF6F5), // Light pink background
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.transparent, // Mengikuti desain gambar merah dengan transparansi
                                ),
                                child: const Icon(Icons.description_outlined, size: 48, color: Color(0xFFEF4444)),
                              ),
                            ),
                          )
                        : Image.network(
                            imageUrl ?? 'https://picsum.photos/200/300',
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF475569).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPdf ? 'PDF' : 'IMAGE',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Half (Details)
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textPrimary, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(size, style: const TextStyle(fontSize: 10, color: textSecondary)),
                        Text(date, style: const TextStyle(fontSize: 10, color: textSecondary)),
                      ],
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

  void _showPreviewDialog(bool isPdf, String title, String? imageUrl) {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: Get.height * 0.7,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              clipBehavior: Clip.hardEdge,
              child: isPdf
                  ? PdfPreview(
                      build: (format) async => await _generateMockPdf(title),
                      useActions: false,
                      allowPrinting: false,
                      allowSharing: false,
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      padding: EdgeInsets.zero,
                    )
                  : Image.network(imageUrl ?? 'https://picsum.photos/400/600', fit: BoxFit.contain),
            ),
            Positioned(
              top: 12, right: 12,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _generateMockPdf(String title) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Icon(const pw.IconData(0xe873), size: 100, color: const PdfColor.fromInt(0xFFEF4444)), // document icon equivalent if supported, else just text
              pw.SizedBox(height: 20),
              pw.Text('Pratinjau Dokumen Mockup:', style: pw.TextStyle(fontSize: 18, color: const PdfColor.fromInt(0xFF64748B))),
              pw.SizedBox(height: 10),
              pw.Text(title, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF0F172A))),
            ]
          )
        ),
      ),
    );
    return pdf.save();
  }

  // ✅ Header sekarang menerima boolean isSelesai untuk menyesuaikan warna lekukan S-Curve
  Widget _buildHeader(bool isSelesai) {
    Color patchColor = isSelesai ? bgSelesai : whiteBgColor;

    return Stack(
      children: [
        Positioned(
          bottom: 0, left: 0,
          child: SizedBox(width: 50, height: 50, child: DecoratedBox(decoration: BoxDecoration(color: patchColor))),
        ),
        Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(color: darkBlueColor, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.zero)),
          child: Stack(
            children: [
              Positioned(
                top: -10, right: -5,
                child: Opacity(opacity: 0.8, child: Image.asset('assets/images/icons/building_illustration3.png', width: 300, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.location_city, size: 200, color: Colors.white10))),
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
              SizedBox(
                width: 20,
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    _buildTimelineDot(isCurrent, isDone),
                    if (!isLast) Expanded(child: Container(width: 1.5, color: isDone ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0), margin: const EdgeInsets.symmetric(vertical: 4))),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isCurrent ? darkBlueColor : (isDone ? textPrimary : const Color(0xFF94A3B8)))),
                      const SizedBox(height: 6),
                      Text(
                        isCurrent 
                          ? 'Tim paralegal sedang mengatur jadwal pertemuan mediasi dengan pihak tertuduh.' 
                          : (item.tanggal ?? 'Menunggu proses selanjutnya'), 
                        style: TextStyle(fontSize: 13, color: isDone ? textSecondary : const Color(0xFF94A3B8), height: 1.5)
                      ),
                      if (isCurrent) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Estimasi: 3 Hari', style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
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
    if (isCurrent) {
      return Container(
        width: 16, height: 16, 
        decoration: BoxDecoration(
          shape: BoxShape.circle, 
          color: darkBlueColor, 
          border: Border.all(color: const Color(0xFFFDE68A), width: 3)
        )
      );
    } else if (isDone) {
      return Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFCBD5E1)));
    } else {
      return Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: whiteBgColor, border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5)));
    }
  }

  Widget _buildBottomButtons() {
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
            children: [
              Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20), 
              SizedBox(width: 8), 
              Text('Chat Paralegal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))
            ]
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  LAYOUT 2: KETIKA STATUS "SELESAI"
  // ════════════════════════════════════════════════════════════════════
  Widget _buildSelesaiLayout(DetailKasus kasus, bool isSelesai) {
    return Column(
      children: [
        // ✅ Tampilkan Header Biasa
        _buildHeader(isSelesai),

        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: bgSelesai, // Background abu-abu terang sesuai Container.png
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(28),
                topLeft: Radius.zero,
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 24), // Padding atas disesuaikan
              child: Column(
                children: [
                  _buildSelesaiHeaderCard(kasus),
                  const SizedBox(height: 16),
                  _buildSelesaiPutusanCard(kasus),
                  const SizedBox(height: 16),
                  _buildSelesaiTimelineCard(kasus),
                  const SizedBox(height: 16),
                  _buildSelesaiInfoRow(kasus),
                  const SizedBox(height: 24),
                  _buildSelesaiUnduhButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelesaiHeaderCard(DetailKasus kasus) {
    String tglSelesai = kasus.tanggalDibuat;
    if (kasus.timeline.isNotEmpty && kasus.timeline.last.tanggal != null) {
      tglSelesai = kasus.timeline.last.tanggal!;
    }

    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(height: 5, color: const Color(0xFF10B981)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFFECFDF5), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 36),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(20)),
                  child: const Text('PERKARA SELESAI', style: TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 16),
                Text(kasus.judulKasus, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.3)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text('NO. PERKARA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                        const SizedBox(height: 6),
                        Text('#${kasus.idKasus.toUpperCase()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      ],
                    ),
                    Container(height: 35, width: 1, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 24)),
                    Column(
                      children: [
                        const Text('TGL. SELESAI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                        const SizedBox(height: 6),
                        Text(tglSelesai, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelesaiPutusanCard(DetailKasus kasus) {
    String rawCatatan = kasus.catatanParalegal ?? '';
    List<String> listPutusan = rawCatatan.trim().isNotEmpty
        ? rawCatatan.split('\n').where((text) => text.trim().isNotEmpty).toList()
        : [
      'Tanah dibagi rata menjadi 4 bagian dengan masing-masing luas 125m².',
      'Sertifikat hak milik (SHM) baru sedang dalam proses penerbitan.'
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                child: const Icon(Icons.workspace_premium_outlined, color: Color(0xFF3B82F6), size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hasil Putusan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  SizedBox(height: 2),
                  Text('Kesepakatan Mediasi Final', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Color(0xFFF1F5F9))),

          ...listPutusan.map((putusan) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(putusan.trim(), style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.5))),
              ],
            ),
          )).toList(),

        ],
      ),
    );
  }

  Widget _buildSelesaiTimelineCard(DetailKasus kasus) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Alur Penanganan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                child: const Text('100% Tuntas', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w800)),
              )
            ],
          ),
          const SizedBox(height: 24),
          ...List.generate(kasus.timeline.length, (index) {
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
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            color: isLast ? Colors.white : const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: isLast ? Border.all(color: const Color(0xFF10B981), width: 3) : null,
                          ),
                          child: isLast ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle))) : const Icon(Icons.check, color: Colors.white, size: 12),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2, color: const Color(0xFF10B981),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                      child: isLast
                          ? Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDCFCE7))),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.insert_drive_file_outlined, color: Color(0xFF15803D), size: 16),
                                    const SizedBox(width: 8),
                                    Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text('Perkara resmi ditutup. Berkas kesepakatan telah ditandatangani kedua belah pihak.', style: TextStyle(fontSize: 12, color: Color(0xFF166534), height: 1.5)),
                              ]
                          )
                      )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          const SizedBox(height: 4),
                          Text(item.tanggal ?? 'Selesai', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSelesaiInfoRow(DetailKasus kasus) {
    return Row(
      children: [
        Expanded(
            child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFFF8FAFC), shape: BoxShape.circle), child: const Icon(Icons.balance, color: Color(0xFF64748B), size: 18)),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('KATEGORI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                        SizedBox(height: 2),
                        Text('Perdata', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      ],
                    )
                  ],
                )
            )
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFFF8FAFC), shape: BoxShape.circle), child: const Icon(Icons.location_on_outlined, color: Color(0xFF64748B), size: 18)),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WILAYAH', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                        SizedBox(height: 2),
                        Text('Pekanbaru', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      ],
                    )
                  ],
                )
            )
        )
      ],
    );
  }

  Widget _buildSelesaiUnduhButton() {
    return ElevatedButton(
      onPressed: () { Get.snackbar('Info', 'Mengunduh Salinan Putusan...'); },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F172A),
        padding: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        shadowColor: const Color(0xFF0F172A).withOpacity(0.3),
      ),
      child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.description_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Unduh Salinan Putusan', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('PDF Resmi • 3.2 MB', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
            ),
          ]
      ),
    );
  }
}